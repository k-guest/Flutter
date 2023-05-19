import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpdw_flutter/model/product.dart';
import 'package:lpdw_flutter/res/app_colors.dart';
import 'package:lpdw_flutter/screens/details/product_bloc.dart';

class ProductNutrition extends StatefulWidget {
  static const double kImageHeight = 300.0;

  const ProductNutrition({Key? key}) : super(key: key);

  @override
  State<ProductNutrition> createState() => _ProductNutritionState();
}

double _scrollProgress(BuildContext context) {
  ScrollController? controller = PrimaryScrollController.of(context);
  return !controller.hasClients
      ? 0
      : (controller.position.pixels / ProductNutrition.kImageHeight)
          .clamp(0, 1);
}

class _ProductNutritionState extends State<ProductNutrition> {
  double _currentScrollProgress = 0.0;

  void _onScroll() {
    if (_currentScrollProgress != _scrollProgress(context)) {
      setState(() {
        _currentScrollProgress = _scrollProgress(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController =
        PrimaryScrollController.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        _onScroll();
        return false;
      },
      child: Stack(children: [
        Image.network(
          (BlocProvider.of<ProductBloc>(context).state as LoadedProductState)
                  .product
                  .picture ??
              '',
          width: double.infinity,
          height: ProductNutrition.kImageHeight,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(_currentScrollProgress),
          colorBlendMode: BlendMode.srcATop,
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Scrollbar(
              controller: scrollController,
              trackVisibility: true,
              child: Container(
                margin: const EdgeInsetsDirectional.only(
                  top: ProductNutrition.kImageHeight - 30.0,
                ),
                child: const _Body(),
              ),
            ),
          ),
        ),
      ]),
    );
  }
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

class _Body extends StatelessWidget {
  static const double _kHorizontalPadding = 20.0;
  static const double _kVerticalPadding = 30.0;

  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(16.0),
          topEnd: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _kHorizontalPadding,
              vertical: _kVerticalPadding,
            ),
            child: _Header(),
          ),
          _Ingredients(),
          _Substance(),
          _Additives(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ProductBloc, ProductState>(
        builder: (BuildContext context, ProductState state) {
      final Product product = (state as LoadedProductState).product;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.name != null)
            Text(
              product.name!,
              style: textTheme.displayLarge,
            ),
          const SizedBox(
            height: 3.0,
          ),
          if (product.brands != null) ...[
            Text(
              product.brands!.join(", "),
              style: textTheme.displayMedium,
            ),
          ],
        ],
      );
    });
  }
}

class _Ingredients extends StatelessWidget {
  const _Ingredients({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
        builder: (BuildContext context, ProductState state) {
      final Product product = (state as LoadedProductState).product;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppColors.gray1,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              'Ingrédients',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 10.0),
          _ProductItemValue(
            label: 'Légumes',
            value: '${product.vegetables}',
          ),
          _ProductItemValue(
            label: 'Eau',
            value: '${product.water}',
          ),
          _ProductItemValue(
            label: 'Sucre',
            value: '${product.sugar}',
          ),
          _ProductItemValue(
            label: 'Garniture (2,5%)',
            value: '${product.trim}',
          ),
          _ProductItemValue(
            label: 'Sel',
            value: '${product.salt}',
          ),
          _ProductItemValue(
            label: 'Arômes naturels',
            value: '${product.naturalFlavors}',
            includeDivider: false,
          ),
          const SizedBox(
            height: 15.0,
          ),
        ],
      );
    });
  }
}

class _Substance extends StatelessWidget {
  const _Substance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
        builder: (BuildContext context, ProductState state) {
      final Product product = (state as LoadedProductState).product;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppColors.gray1,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              'Substances allergènes',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 10.0),
          _ProductItemValue(
            label: '${product.allergenicSubstances}',
            value: '',
            includeDivider: false,
          ),
          const SizedBox(
            height: 15.0,
          ),
        ],
      );
    });
  }
}

class _Additives extends StatelessWidget {
  const _Additives({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
        builder: (BuildContext context, ProductState state) {
      final Product product = (state as LoadedProductState).product;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppColors.gray1,
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              'Additifs',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 10.0),
          _ProductItemValue(
            label: '${product.additivesNutrition}',
            value: '',
            includeDivider: false,
          ),
          const SizedBox(
            height: 15.0,
          ),
        ],
      );
    });
  }
}

class _ProductItemValue extends StatelessWidget {
  final String label;
  final String value;
  final bool includeDivider;

  const _ProductItemValue({
    required this.label,
    required this.value,
    this.includeDivider = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          if (includeDivider) const Divider(height: 1.0)
        ],
      ),
    );
  }
}
