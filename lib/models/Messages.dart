import 'dart:convert' show json;
import 'package:aircolis/utils/constants.dart';
import 'package:aircolis/utils/utils.dart';
import 'package:http/http.dart' as http;

class Messages {
  final String _accountSid;
  final String _authToken;

  const Messages(this._accountSid, this._authToken);

  Future<Map> create(data) async {
    var client = http.Client();

    var url = Uri.parse('$TWILIO_SMS_API_BASE_URL/Accounts/$_accountSid/Messages.json');

    try {
      var response = await client.post(url, headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + Utils.toAuthCredentials(_accountSid, _authToken)
      }, body: {
        'From': data['from'],
        'To': data['to'],
        'Body': data['body']
      });

      return (json.decode(response.body));
    } catch (e) {
      return ({'Runtime Error': e});
    } finally {
      client.close();
    }
  }
}