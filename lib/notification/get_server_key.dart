import 'package:googleapis_auth/auth_io.dart';
class GetServerKey {

  Future<String> getServerTokenKey() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];
    
    final client= await clientViaServiceAccount(ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "skill-link47",
      "private_key_id": "d472b7f2193fccadb5cc0ff531c63a17fa794bfb",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCuO6en270BCvjD\n+5zmJCYyzkiAxvUrY49NBw/onCAp8K1qRysDEQvVdSW1xgwGKPI+3QZjy8iU/dPp\nBff8fUQqwf9vt9AKHimMNvOpCK6/onfg7H9w9oMW6AV6x+JcfD2o0g92Tosn7fIX\n1DYfMEyhLAdZ5FlN62+vfs6kalbg89ps565JyfCdbgx8u6kvzHz2/7l1KfZ8P8JZ\nXTfW20/bpGrq9V8GaZbqo/UTmRvcE3kCjElQw/L2ab9dGh4uJQSZr5dec+YUGTgV\nKmxxYztSp6neTLBXW+mNYmmkTJRaHdsJ4PSzB+CZwO6EQpQX89GF7AijUqeHrmjj\nHsdxYN6rAgMBAAECggEAAQRwJ4Fs9RiZ+JWmMOHSfJwfvZYWew5gbn61ZRJO+G+4\nqNTe4hcIuVJZygSXWrcv0ut6IhMKih7Woexa/6prlM7/2Ch779Mv7ZWp4+QdFm6z\nFykfsAqAcXMhX7ooZDSFglAtBEUpItk3f1QfN3ISFc7VVtJdLctLd6bckLEzmKn8\nCb2MMwrumK8GDK+TtY3F14fGaMFi2gQEhhgJKAC4O1P/0MQqzrDEs/ADQ5FuHvil\nqwHc9YD+0YsYVmtfTVotTWRvkWGoXZNcP0AenADy5aQ2XgJS8NmN2zMaNoq38R2u\nARUN83ATiwZrCSmBV850UXiJhG/i2Y0DM9AQxLD6gQKBgQDk75QPvKw7qOkQVvKj\n3fAef4r7LU7QdFsFRIo4sGzmILSm8XAa9snG5E5qzxNgp9c6AYmm/WCbFaOlJXPe\nj6lH1blo/BTCGfqWXmSxllQgSrx2fAFcuwMpRlussdMiS+qRQl7hhvx+lKT4vfmm\nFl91GiGMXAWSPuUX9cFmuTmPUQKBgQDC1JKLbLGSbL7rZOuLQNBJFEF+mEWOyxpX\nxCvOEKkgji7HB83NTJAppKEASk1MVEdqDOt3CrjCHCYSEXz1GXrafTlUani7PE9d\nEYJ6jNwbFQCaQpzA/Fmd4LLWm1QawGecq5ghHU72sNeuskybEOD9B1D11DAf6zhP\ne64o6O+nOwKBgCXgiZOs+KYKRT1B1XVNM/wnx/vUvDR6+9A8Tc4hSnMsuBbi3VRo\nvmucvGipiCA2xMJBHOA3DbO6+c9KCgippi1PbBS1mE2g9LfKOEi1gYeyNco4rBUG\nj/hVPres2CzVeKK942rW5ZGf0EejTtmu2+5I+4H4e6d9pnO3Yl83iBFxAoGBALcM\njZrdRoDyFvaG3R76iDcBBv/wBPpCLL/lGdsDoENsEtsApAWNN61IddQV+0YJsQcc\nmGZB9pC5bbNwJt0JUXnSSXjciA4yfcZNWy/VBD+VnflROIHBFlnU8XHcgkqYF0EF\nn2sNZFE2mY4TCxJt61UP+Kre71At6bwT0e+x2uhdAoGAA+cnuOat+aMPn/cKthWR\nvGnk0kA8HcJvKJ+AH5RE1UWTX0cE6ZKJdOgV5U4CGYYepcnMGK9xURz4oCzbHdVY\nWAYbnbtYhu+5OGbljdysCo+8VRz1drGCStyk2N5qI3PmwfQdOoe3AsWfNnBM6ioZ\n/D1QKrpLA9lsSaGkc1sWHL0=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-fbsvc@skill-link47.iam.gserviceaccount.com",
      "client_id": "115797041816771520780",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40skill-link47.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    }
    ), scopes);

    final accessToken = await client.credentials.accessToken.data;
    return accessToken;
    
  }

}