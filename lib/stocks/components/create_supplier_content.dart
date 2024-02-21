import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartstock/core/components/CancelProcessButtonsRow.dart';
import 'package:smartstock/core/components/TextInput.dart';
import 'package:smartstock/core/components/WhiteSpacer.dart';
import 'package:smartstock/core/components/info_dialog.dart';
import 'package:smartstock/core/helpers/functional.dart';
import 'package:smartstock/core/services/cache_shop.dart';
import 'package:smartstock/core/helpers/util.dart';
import 'package:smartstock/stocks/services/api_suppliers.dart';

class CreateSupplierContent extends StatefulWidget {
  final VoidCallback onDone;

  const CreateSupplierContent({super.key, required this.onDone});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<CreateSupplierContent> {
  var _name = '';
  var _number = '';
  var _address = ' ';
  var _errors = {};
  var _createProgress = false;

  @override
  Widget build(BuildContext context) {
    var form = ListView(
      shrinkWrap: true,
      children: [
        TextInput(
          onText: (d) {
            _updateState(() {
              _name = d;
              _errors = {..._errors, 'name': ''};
            });
          },
          label: "Name",
          error: '${_errors['name'] ?? ''}',
        ),
        TextInput(
          onText: (d) {
            _updateState(() {
              _number = d;
              _errors = {..._errors, 'number': ''};
            });
          },
          label: "Mobile",
          error: '${_errors['number'] ?? ''}',
          // placeholder: 'Optional',
        ),
        // TextInput(
        //     onText: (d) => updateState({'email': d}),
        //     label: "Email",
        //     placeholder: 'Optional'),
        TextInput(
            onText: (d) {
              _updateState(() {
                _address = d;
                // _errors = {..._errors,'address':''};
              });
            },
            label: "Address",
            lines: 3,
            placeholder: 'Optional'),
      ],
    );
    var isSmallScreen = getIsSmallScreen(context);
    return Container(
      padding: const EdgeInsets.all(16),
      width: isSmallScreen ? null : 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isSmallScreen ? Expanded(child: form) : form,
          const WhiteSpacer(height: 16),
          CancelProcessButtonsRow(
            cancelText: 'Cancel',
            onCancel: () {
              Navigator.of(context).maybePop();
            },
            proceedText: _createProgress ? "Waiting..." : "Proceed",
            onProceed: _createProgress ? null : _submit,
          )
        ],
      ),
    );
  }

  _updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  _validateName() {
    var isString = ifDoElse((x) => x, (x) => x, (x) {
      _errors['name'] = 'Name required';
      return x;
    });
    return isString(_name.isNotEmpty);
  }

  _validateMobile() {
    var isString = ifDoElse((x) => x, (x) => x, (x) {
      _errors['number'] = 'Mobile number required';
      return x;
    });
    return isString(_number.isNotEmpty);
  }

  _validSupplier() {
    var hasNoError = true;
    if (!_validateName()) {
      hasNoError = false;
    }
    if (!_validateMobile()) {
      hasNoError = false;
    }
    _updateState(() {});
    return hasNoError;
  }

  _submit() async {
    _updateState(() {
      _errors = {};
      _createProgress = true;
    });
    var shop = await getActiveShop();
    var createIFValid = ifDoElse(
      (_) => _validSupplier(),
      (_) => productCreateSupplierRestAPI({
        'name': _name,
        'number': _number,
        'address': _address,
        'id': _name.toLowerCase()
      }, shop),
      (_) async => 'nope',
    );
    return createIFValid(shop).then((r) {
      if (r == 'nope') return;
      widget.onDone();
      showInfoDialog(context, 'Vendor created successful').whenComplete(() {
        Navigator.of(context).maybePop();
      });
    }).catchError((err) {
      showInfoDialog(context, '$err, Please try again');
    }).whenComplete(() {
      _updateState(() {
        _createProgress = false;
      });
    });
  }
}
