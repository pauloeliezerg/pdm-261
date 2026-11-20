# Tutorial: Carrinho de Compras com Flutter + Provider

Este tutorial cria um aplicativo Flutter que simula um carrinho de compras,
usando `provider` como gerenciamento de estado. Ao final, o app será
executado em um emulador Android.

## 1. Pré-requisitos

- Flutter SDK (canal stable, versão 3.x).
- Android SDK com platform 34 e build-tools.
- Um emulador Android (AVD) configurado.
- Editor de código (VS Code, Android Studio ou outro).

Se você já tem o ambiente pronto, pule a seção 2 e vá para a 3.

## 2. Configuração do ambiente

### 2.1 Instalar o Flutter

Baixe o Flutter SDK em https://docs.flutter.dev/get-started/install e
adicione o diretório `bin` do Flutter ao `PATH`.

Valide a instalação:

```bash
flutter --version
```

### 2.2 Android SDK e emulador

A forma mais simples em qualquer sistema é usar o Android Studio:

1. Instale o Android Studio.
2. Em "SDK Manager", instale:
   - Android SDK Platform 34
   - Android SDK Build-Tools
   - Android SDK Platform-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Uma System Image (por exemplo, "Google APIs x86_64 — API 34")
3. Em "AVD Manager", crie um AVD chamado `pixel` com a system image
   instalada.

Em ambientes que já possuem o SDK, o mesmo pode ser feito pela linha
de comando:

```bash
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" \
           "emulator" "system-images;android-34;google_apis;x86_64"
avdmanager create avd -n pixel -k "system-images;android-34;google_apis;x86_64"
```

Aceite as licenças se solicitado:

```bash
flutter doctor --android-licenses
```

### 2.3 Verificar o ambiente

```bash
flutter doctor
```

Resolva eventuais pendências antes de continuar. A saída ideal para este
tutorial exige, no mínimo, Flutter, Android toolchain e um dispositivo/emulador
disponível.

## 3. Criar o projeto

```bash
flutter create carrinho_compras
cd carrinho_compras
```

## 4. Adicionar a dependência `provider`

Edite `pubspec.yaml` e adicione:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
```

Baixe o pacote:

```bash
flutter pub get
```

## 5. Estrutura do projeto

O código-fonte do app ficará organizado da seguinte forma:

```
lib/
├── main.dart
├── data/
│   └── sample_products.dart
├── models/
│   ├── cart_item.dart
│   └── product.dart
├── providers/
│   └── cart_provider.dart
└── screens/
    ├── cart_screen.dart
    └── catalog_screen.dart
```

## 6. Modelos de dados

Crie `lib/models/product.dart`:

```dart
class Product {
  final String id;
  final String name;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.price,
  });
}
```

Crie `lib/models/cart_item.dart`:

```dart
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}
```

## 7. Provider do carrinho

Crie `lib/providers/cart_provider.dart`:

```dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    for (final cartItem in _items.values) {
      total += cartItem.totalPrice;
    }
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
```

## 8. Produtos de exemplo

Crie `lib/data/sample_products.dart`:

```dart
import '../models/product.dart';

final List<Product> sampleProducts = [
  Product(id: 'p1', name: 'Camiseta', price: 59.90),
  Product(id: 'p2', name: 'Calça Jeans', price: 129.90),
  Product(id: 'p3', name: 'Tênis', price: 249.90),
  Product(id: 'p4', name: 'Boné', price: 39.90),
];
```

## 9. `main.dart`

Substitua o conteúdo de `lib/main.dart` por:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinho de Compras',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CatalogScreen(),
    );
  }
}
```

## 10. Tela de catálogo

Crie `lib/screens/catalog_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/sample_products.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cart.itemCount}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: sampleProducts.length,
        itemBuilder: (ctx, index) {
          final product = sampleProducts[index];
          return ListTile(
            title: Text(product.name),
            subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false)
                    .addItem(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} adicionado ao carrinho'),
                    duration: const Duration(milliseconds: 600),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

## 11. Tela do carrinho

Crie `lib/screens/cart_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Carrinho vazio'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final entry = cart.items.entries.elementAt(i);
                      final cartItem = entry.value;
                      return ListTile(
                        title: Text(cartItem.product.name),
                        subtitle: Text(
                          'R\$ ${cartItem.product.price.toStringAsFixed(2)}'
                          ' x ${cartItem.quantity}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .removeSingleItem(entry.key);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .addItem(cartItem.product);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
```

## 12. Criar e iniciar o emulador Android

### Opção A — Android Studio (GUI)

Abra o AVD Manager e inicie o AVD `pixel`.

### Opção B — linha de comando

```bash
emulator -avd pixel &
```

Se o emulador não iniciar ou apresentar problemas gráficos, tente:

```bash
emulator -avd pixel -gpu host
# ou, como fallback:
emulator -avd pixel -gpu swiftshader_indirect
```

Também é possível iniciar via Flutter:

```bash
flutter emulators
flutter emulators --launch pixel
```

### Confirmar que o emulador está ativo

```bash
adb devices
```

Deve aparecer algo como:

```
emulator-5554   device
```

E:

```bash
flutter devices
```

deve listar o emulador.

## 13. Executar o aplicativo

Com o emulador em execução:

```bash
flutter run
```

Se houver mais de um dispositivo conectado, escolha o emulador:

```bash
flutter run -d emulator-5554
```

O Flutter compilará o app, instalará no emulador e o abrirá
automaticamente.

## 14. Roteiro de teste manual

1. Na tela **Catálogo**, toque no ícone de carrinho ao lado de um produto.
   Um `SnackBar` confirma a inclusão e o contador no topo é incrementado.
2. Adicione o mesmo produto mais de uma vez — o contador de itens distintos
   permanece igual, mas a quantidade no carrinho aumenta.
3. Toque no ícone do carrinho na `AppBar` para abrir a tela **Carrinho**.
4. No carrinho, use os botões `+` e `-` para alterar quantidades. O valor
   total é recalculado a cada alteração.
5. Reduza um item até zero para removê-lo.
6. Esvazie o carrinho e confirme que a tela exibe "Carrinho vazio".

## 15. Solução de problemas

- **`flutter doctor` reclama das licenças**:
  execute `flutter doctor --android-licenses` e aceite todas.
- **Flutter não encontra o Android SDK**:
  execute `flutter config --android-sdk <caminho-do-sdk>`.
- **Emulador lento ou sem aceleração**:
  confirme que a virtualização por hardware está habilitada na BIOS e
  (em Linux) que o usuário tem acesso a `/dev/kvm`.
- **Tela do emulador preta ou travada**:
  reinicie com `-gpu swiftshader_indirect` e, se necessário, use
  `-no-snapshot -wipe-data`.
- **`provider` não é encontrado**:
  rode `flutter pub get` novamente e reinicie o `flutter run`.

## 16. Próximos passos sugeridos

- Persistir o carrinho com `shared_preferences` ou um banco local.
- Consumir produtos de uma API REST.
- Adicionar testes de unidade ao `CartProvider`.
- Explorar outras estratégias de gerenciamento de estado
  (`Riverpod`, `Bloc`) para comparar com `Provider`.
