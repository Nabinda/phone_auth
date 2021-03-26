import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  OTPScreen(this.phone);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _verificationCode;
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+977${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async{
          await FirebaseAuth.instance.signInWithCredential(credential).then((value) async{
           if(value.user!=null){
             print("Logged In");
           }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Error in Firebase Auth" + e.message);
        },
        codeSent: (String verificationId, int resendToken) {
          setState(() {
            _verificationCode = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationCode = verificationId;
          });
        },
        timeout: Duration(seconds: 100));
  }
  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Center(
              child: Text('Verify +977-${widget.phone}'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: PinPut(
              fieldsCount: 6,
              withCursor: true,
              textStyle: const TextStyle(fontSize: 25.0, color: Colors.white),
              eachFieldWidth: 40.0,
              eachFieldHeight: 55.0,
              onSubmit: (String pin) async{
                try {
                  await FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(verificationId: _verificationCode, smsCode: pin)).then((value) async{
                    if(value.user != null){
                      print("Logged In Successfully");
                    }
                  });
                }  catch (e) {
                  FocusScope.of(context).unfocus();
                  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Invalid OTP")));
                }
              },
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              submittedFieldDecoration: pinPutDecoration,
              selectedFieldDecoration: pinPutDecoration,
              followingFieldDecoration: pinPutDecoration,
              pinAnimationType: PinAnimationType.fade,
            ),
          )
        ],
      ),
    );
  }
}
