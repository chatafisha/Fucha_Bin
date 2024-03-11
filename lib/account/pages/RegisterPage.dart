import 'package:flutter/material.dart';
import 'package:smartstock/account/components/RegisterForm.dart';
import 'package:smartstock/core/components/BodyLarge.dart';
import 'package:smartstock/core/components/TitleLarge.dart';
import 'package:smartstock/core/components/WhiteSpacer.dart';
import 'package:smartstock/core/components/logo_white.dart';
import 'package:smartstock/core/components/surface_with_image.dart';
import 'package:smartstock/core/helpers/util.dart';
import 'package:smartstock/core/pages/page_base.dart';

class RegisterPage extends PageBase {
  final OnGeAppMenu onGetModulesMenu;
  final OnGetInitialPage onGetInitialModule;

  const RegisterPage({
    super.key,
    required this.onGetModulesMenu,
    required this.onGetInitialModule,
  }) : super(pageName: 'RegisterPage');

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<RegisterPage> {
  @override
  Widget build(var context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const BodyLarge(text: 'Open an account'),
        centerTitle: true,
      ),
      body: SurfaceWithImage(
        child: ListView(
          // shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            const TitleLarge(text: 'Welcome to Chatafisha, your one step'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TitleLarge(text: 'away from making'),
                const WhiteSpacer(width: 8),
                TitleLarge(
                    text: 'real + impact',
                    color: Theme.of(context).colorScheme.primary)
              ],
            ),
            const WhiteSpacer(height: 24),
            _getBody(context)
          ],
        ),
      ),
    );
  }

  Widget _getRegisterForm(BuildContext context) {
    return RegisterForm(
      onGetModulesMenu: widget.onGetModulesMenu,
      onGetInitialModule: widget.onGetInitialModule,
    );
  }

  Widget _getImpactImage(BuildContext context) {
    return Container(
      height: 350,
      // padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary,
        image: const DecorationImage(
          image: AssetImage("assets/images/impact.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(child: Container()),
                const LogoWhite(size: 48)
              ],
            ),
            Expanded(child: Container()),
            const WhiteSpacer(height: 16),
            TitleLarge(
              text: 'Pata thamani',
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            BodyLarge(
              text:
              'Earn carbon credits through the offsets of plastic waste into usable goods and building materials.',
              color: Theme.of(context).colorScheme.onPrimary,
            )
          ],
        ),
      ) /* add child content here */,
    );
  }

  Widget _getBody(BuildContext context) {
    var isSmallScreen = getIsSmallScreen(context);
    return isSmallScreen
        ? _getSmallScreenView(context)
        : _getLargeScreenView(context);
  }

  Widget _getSmallScreenView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _getRegisterForm(context),
        const WhiteSpacer(width: 24),
        _getImpactImage(context),
      ],
    );
  }

  Widget _getLargeScreenView(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _getRegisterForm(context)),
        const WhiteSpacer(width: 24),
        Expanded(child: _getImpactImage(context)),
        const WhiteSpacer(width: 24),
      ],
    );
  }
}
