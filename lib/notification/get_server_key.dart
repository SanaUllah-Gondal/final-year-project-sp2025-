// get_server_key.dart
import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  Future<String> getServerTokenKey() async {
    try {
      // Use the CORRECT service account JSON (the second one you provided)
      final serviceAccount = ServiceAccountCredentials.fromJson(_getServiceAccountJson());

      final authClient = await clientViaServiceAccount(serviceAccount, _scopes);
      final accessToken = authClient.credentials.accessToken.data;

      await authClient.close;

      print('✅ Server access token obtained successfully: ${accessToken.substring(0, 50)}...');
      return accessToken;
    } catch (e) {
      print('❌ Error getting server access token: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _getServiceAccountJson() {
    return {
      "type": "service_account",
      "project_id": "skill-link47",
      "private_key_id": "fad72f91e709a8b3939b6697afec51a976e78e30", // Use the correct private_key_id
      "private_key": _getPrivateKey(), // Properly formatted private key
      "client_email": "firebase-adminsdk-fbsvc@skill-link47.iam.gserviceaccount.com",
      "client_id": "115797041816771520780",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40skill-link47.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
  }

  String _getPrivateKey() {
    return '''-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCW0jm6k39NVW+h
Xq2OA4rifGO0LcRQG9906q2WmTEX55DgZXd5Ov2y83cDm92C3e6lGc7UZolyk35/
FMBCtPSSZXNqQoUhM9Puhs1KOK3YAkZudSi90IbyeYyP0aD6VM7QaCs5fHQoZSj2
ddDle62PZB+OwApPvDSOg9gtg1l7pVGG9QL7tyrrwHe/iBLB/RXrLlO/nAlplPZ/
3BX9pzNG74EVRXVmRD/aCnDFTcS++U0Ri/Jdg6D0nqtyZgL3vUep4EW2GwJmrlkY
tumDRhdn91SgN5+OZwcaynkdsYyp3s5WBl9sy4vS5GwgC5BjdeQhUvwVYlsS6Ynw
uHGB9pgfAgMBAAECggEAEyS69B4treS2xx5L3DdB5S6RvziB7wMisWXqQ6/NJfIc
Fwd6Cza8Jf82L4yUqLw/wtAMSzR6pMLo7vt0zeLHGl/rLuUjncvEzkVpAE9CbaUY
SIPxeGpj/poEB+s9ShkCqTxXpDPSUKBKe0IIEmDI7mbwhH+Gr4k9iIteoKRH8uQe
k1YZpO9dmI1t+rDRdC4WxDrgxlnMktYGfklPAo6ooB6mX8sLgPw4+PEcPHbYKcyU
0H2BpWM9ouGVd51z66zrRr4yhB6ncGgaNvFZ374VBsbuNZaah49ewYdy547JuCeq
8UwCVW3T1N4/xmMojC2FzIIweRZ1H/4mZS+lvJ33KQKBgQDLuYhFypWpir7DJjQ5
/WIhoTSEvggFCOIJ+or3V+RBuD3y2lqCdgHoy9iGJfd/pp6UNFrhZTkAM5L5gBpx
1eWVsp3QXq864kdARyKOcpZ1K9wKmqcXx5bL+JOqdUkCoR9AL8QIVe+rhLF27jN7
0Nr4YfaQHdyzMUXQttCi05I9WQKBgQC9hYOa9DJOtfWr6q/X7+dyVShymQykJA3e
XsMdotUsCUq02rABkix14wACfGe3HHxusdHz4Cb1kMyoWp/H8ClfeBVpWE7pKuSb
r+ENVzFDozAjtOD8xvxaMEGoTABL5tKSMoouDZNJLg1kjI4F2huy2/9QLyJeq3O7
1Oqv6ed6NwKBgCQ7s0j2ZvfofVUoDlHiBvoEOdsCEVsT4V/095JWR3qI0jvHKiHZ
6y0EVFZHmmVRtRKW3TMJVcH7akCF0C4+5L5jLj5JGNFYPWPpQvQi3S+pxVD9gIpy
LRfJ9jly8rFNBsnbtPnmjuHqj8WfR/jVhJx4j+nB5ebY9JnSafkLuA7BAoGAf5Qi
LKxYNT4uO+WHK/C2N/P1f3dh2BjhMSFPbWLQ54z1ultAgj45Kb5+oi3Gz7AgX4/a
irYI4+PusSIYT0pvP3Ihz8F/lVynedpiwE1Cv4pZ/J9lmSQGelvjxvwqcu3WME5P
UIMY8/lJULeBX5UcckHAU+T22Q3HodjJh1QI2+8CgYAqfmiieY76lUVTzj8TCVoS
g7Z/pss0VMLxm2ugwmw80gnPWGsVpNzNUk+8HotvnZ3hs0pzwbwokYDKsZ83pKpi
nZru1GclnFtTSUg2NghuIS4kfhHagFBAQuWZosMhXHCriMD9EI6VmmTGbwFF6Wk8
54ANgP1xH+RIMlT/VNVesQ==
-----END PRIVATE KEY-----''';
  }
}