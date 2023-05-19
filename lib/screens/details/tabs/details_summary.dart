import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lpdw_flutter/model/product.dart';
import 'package:lpdw_flutter/screens/details/product_bloc.dart';

class ProductSummary extends StatefulWidget {
  static const double kImageHeight = 300.0;

  const ProductSummary({Key? key}) : super(key: key);

  @override
  State<ProductSummary> createState() => _ProductSummaryState();
}

double _scrollProgress(BuildContext context) {
  ScrollController? controller = PrimaryScrollController.of(context);
  return !controller.hasClients
      ? 0
      : (controller.position.pixels / ProductSummary.kImageHeight).clamp(0, 1);
}

class _ProductSummaryState extends State<ProductSummary> {
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
          height: ProductSummary.kImageHeight,
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
                  top: ProductSummary.kImageHeight - 30.0,
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
            const _ProductItemValue(
              label: '',
              value: 'Pour 100g',
              valueRight: 'Par part',
            ),
            _ProductItemValue(
              label: 'Énergie',
              value: '${product.energyTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'Matières grasses',
              value: '${product.fatsLipidsTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'dont Acides gras saturés',
              value: '${product.saturatedFattyAcidsTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'Glucides',
              value: '${product.carbsTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'dont Sucres',
              value: '${product.sugarTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'Fibres alimentaires',
              value: '${product.dietaryFibersTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'Protéines',
              value: '${product.proteinsTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'Sel',
              value: '${product.saltTab}',
              valueRight: '?',
            ),
            _ProductItemValue(
              label: 'Sodium',
              value: '${product.sodiumTab}',
              valueRight: '?',
              includeDivider: false,
            ),
            const SizedBox(
              height: 15.0,
            ),
          ],
        );
      },
    );
  }
}

class _ProductItemValue extends StatelessWidget {
  final String label;
  final String value;
  final String valueRight;
  final bool includeDivider;

  const _ProductItemValue({
    required this.label,
    required this.value,
    required this.valueRight,
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
                const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Container(
                  width: 1.0,
                  height: 50.0,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1.0,
                  height: 50.0,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    valueRight,
                    textAlign: TextAlign.center,
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
