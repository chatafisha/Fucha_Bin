import 'package:flutter/material.dart';
import 'package:smartstock/account/services/profile.dart';
import 'package:smartstock/core/components/button.dart';
import 'package:smartstock/core/components/horizontal_line.dart';
import 'package:smartstock/core/components/info_dialog.dart';
import 'package:smartstock/core/components/table_like_list.dart';
import 'package:smartstock/core/components/text_input.dart';
import 'package:smartstock/core/services/util.dart';

class PaymentBody extends StatefulWidget {
  const PaymentBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PaymentBody> {
  var isReady = false;
  var loading = false;
  var state = {};
  var status = 'PENDING';
  var cost = 10000;
  var balance = 0;

  updateState(map) {
    map is Map
        ? setState(() {
            state.addAll(map);
          })
        : null;
  }

  @override
  void initState() {
    super.initState();
    // setState(() {
    //   isReady = true;
    // });
    // getLocalCurrentUser()
    //     .then((value) {
    //   state['fullname'] =
    //   '${value['firstname'] ?? ''} ${value['lastname']}';
    //   updateState(value);
    // })
    //     .catchError((err) {})
    //     .whenComplete(() {
    //   setState(() {
    //     isReady = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tableLikeListRow([
                tableLikeListTextHeader("Lipa namba"),
                tableLikeListTextHeader("Status")
              ]),
              tableLikeListRow([
                tableLikeListTextHeader("6829508"),
                tableLikeListTextHeader("$status")
              ]),
              tableLikeListRow([
                tableLikeListTextHeader("Cost ( TZS ) / Month"),
                tableLikeListTextHeader("Balance ( TZS )")
              ]),
              horizontalLine(),
              tableLikeListRow([
                tableLikeListTextHeader("$cost"),
                tableLikeListTextHeader("$balance")
              ]),
              const Text(
                  'Ukimaliza weka kumbukumbu namba apo chini. Kisha bofya thibitisha malipo.'),
              TextInput(
                onText: (v) {},
                placeholder: 'Kumbukumbu namba',
              ),
              raisedButton(
                title: 'Thibitisha malipo.',
                height: 40,
              ),
              const Text('Payment modes.'),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('TIGO-PESA'),
                    horizontalLine(),
                    Text('''
                    
                    ''')
                  ],
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('MITANDAO MINGINE'),
                    horizontalLine(),
                    Text('''
                    
                    ''')
                  ],
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('BENKI'),
                    horizontalLine(),
                    Text('''
                    
                    ''')
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _onPressed() {}
}
