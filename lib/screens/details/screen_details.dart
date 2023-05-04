import 'package:flutter/material.dart';
import 'package:lpdw_flutter/model/product.dart';
import 'package:lpdw_flutter/res/app_icons.dart';
import 'package:lpdw_flutter/screens/details/tabs/details_info.dart';
import 'package:lpdw_flutter/screens/details/tabs/details_nutrition.dart';
import 'package:lpdw_flutter/screens/details/tabs/details_nutritional_values.dart';
import 'package:lpdw_flutter/screens/details/tabs/details_summary.dart';

class ProductContainer extends InheritedWidget {
  final Product product;

  const ProductContainer({
    Key? key,
    required Widget child,
    required this.product,
  }) : super(key: key, child: child);

  static ProductContainer of(BuildContext context) {
    final ProductContainer? result =
        context.dependOnInheritedWidgetOfExactType<ProductContainer>();
    assert(result != null, 'No ProductContainer found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ProductContainer oldWidget) {
    return product != oldWidget.product;
  }
}

//region Ecran de détails
class ProductDetails extends StatefulWidget {
  const ProductDetails({Key? key}) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final ScrollController _controller = ScrollController();
  ProductDetailsTab _currentTab = ProductDetailsTab.info;

  @override
  Widget build(BuildContext context) {
    final Widget child;

    switch (_currentTab) {
      case ProductDetailsTab.info:
        child = const ProductInfo();
        break;
      case ProductDetailsTab.nutrition:
        child = const ProductNutrition();
        break;
      case ProductDetailsTab.nutritionalValues:
        child = const ProductNutritionalValues();
        break;
      case ProductDetailsTab.summary:
        child = const ProductSummary();
        break;
    }

    return PrimaryScrollController(
      controller: _controller,
      child: ProductContainer(
        product: _generateFakeProduct(),
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: child),
              const Align(
                alignment: AlignmentDirectional.topStart,
                child: _HeaderIcon(
                  icon: AppIcons.close,
                  tooltip: 'Fermer l\'écran',
                ),
              ),
              const Align(
                alignment: AlignmentDirectional.topEnd,
                child: _HeaderIcon(
                  icon: AppIcons.share,
                  tooltip: 'Partager',
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            onTap: (int selectedPosition) {
              ProductDetailsTab newTab =
                  ProductDetailsTab.values[selectedPosition];

              if (newTab != _currentTab) {
                if (_controller.hasClients) {
                  _controller.jumpTo(0.0);
                }

                setState(() {
                  _currentTab = newTab;
                });
              }
            },
            items: ProductDetailsTab.values.map((e) {
              String? label;
              IconData? icon;

              switch (e) {
                case ProductDetailsTab.info:
                  icon = AppIcons.tab_barcode;
                  label = "Fiche";
                  break;
                case ProductDetailsTab.nutritionalValues:
                  icon = AppIcons.tab_fridge;
                  label = "Caractéristiques";
                  break;
                case ProductDetailsTab.nutrition:
                  icon = AppIcons.tab_nutrition;
                  label = "Nutrition";
                  break;
                case ProductDetailsTab.summary:
                  icon = AppIcons.tab_array;
                  label = "Tableau";
              }

              if (label == null || icon == null) {
                throw Exception("Tab $e not implemented!");
              }

              return BottomNavigationBarItem(
                icon: Icon(icon),
                label: label,
              );
            }).toList(growable: false),
            currentIndex: _currentTab.index,
          ),
        ),
      ),
    );
  }

  Product _generateFakeProduct() {
    return Product(
      barcode: '123456789',
      name: 'Petits pois et carottes',
      brands: ['Cassegrain'],
      altName: 'Petits pois & carottes à l\'étuvée avec garniture',
      nutriScore: ProductNutriscore.A,
      novaScore: ProductNovaScore.Group1,
      ecoScore: ProductEcoScore.D,
      quantity: '200g (égoutté 130g)',
      manufacturingCountries: ['France'],
      picture:
          'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1610&q=80',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

enum ProductDetailsTab {
  info,
  nutrition,
  nutritionalValues,
  summary,
}

class _HeaderIcon extends StatefulWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  const _HeaderIcon({
    required this.icon,
    this.tooltip,
    // ignore: unused_element
    this.onPressed,
  });

  @override
  State<_HeaderIcon> createState() => _HeaderIconState();
}

class _HeaderIconState extends State<_HeaderIcon> {
  double _opacity = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PrimaryScrollController.of(context).addListener(_onScroll);
  }

  void _onScroll() {
    double newOpacity = _scrollProgress(context);

    if (newOpacity != _opacity) {
      setState(() {
        _opacity = newOpacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: widget.tooltip,
            child: InkWell(
              onTap: widget.onPressed ?? () {},
              customBorder: const CircleBorder(),
              child: Ink(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      Theme.of(context).primaryColorLight.withOpacity(_opacity),
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _scrollProgress(BuildContext context) {
  ScrollController? controller = PrimaryScrollController.of(context);
  return !controller.hasClients
      ? 0
      : (controller.position.pixels / ProductInfo.kImageHeight).clamp(0, 1);
}
