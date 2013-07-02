import java.net.MalformedURLException;
import java.net.URL;
import java.security.cert.Certificate;
import java.io.*;
 
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLPeerUnverifiedException;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.security.cert.X509Certificate;

public class HttpsClient {
 
   public static void main(String[] args)
   {
        new HttpsClient().testIt();
   }
 
   TrustManager[] trustAllCerts = new TrustManager[] {
       new X509TrustManager() {
          public java.security.cert.X509Certificate[] getAcceptedIssuers() {
            return null;
          }

          public void checkClientTrusted(X509Certificate[] certs, String authType) {  }

          public void checkServerTrusted(X509Certificate[] certs, String authType) {  }

       }
    };

   private void testIt(){
 
      String https_url = "https://irrlab:8443/";
      URL url;
      try {

         SSLContext sc = SSLContext.getInstance("SSL");
         sc.init(null, trustAllCerts, new java.security.SecureRandom());
         HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

        // Create all-trusting host name verifier
          HostnameVerifier allHostsValid = new HostnameVerifier() {
              public boolean verify(String hostname, SSLSession session) {
                return true;
              }
          };
               // Install the all-trusting host verifier
         HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);

         url = new URL(https_url);
         HttpsURLConnection con = (HttpsURLConnection)url.openConnection();
 
         //dumpl all cert info
         print_https_cert(con);
 
         //dump all the content
         print_content(con);
 
      } catch (Exception e) {
         e.printStackTrace();
      }
 
   }
 
   private void print_https_cert(HttpsURLConnection con){
 
    if(con!=null){
 
      try {
 
    System.out.println("Response Code : " + con.getResponseCode());
    System.out.println("Cipher Suite : " + con.getCipherSuite());
    System.out.println("\n");
 
    Certificate[] certs = con.getServerCertificates();
    for(Certificate cert : certs){
       System.out.println("Cert Type : " + cert.getType());
       System.out.println("Cert Hash Code : " + cert.hashCode());
       System.out.println("Cert Public Key Algorithm : " 
                                    + cert.getPublicKey().getAlgorithm());
       System.out.println("Cert Public Key Format : " 
                                    + cert.getPublicKey().getFormat());
       System.out.println("\n");
    }
 
    } catch (SSLPeerUnverifiedException e) {
        e.printStackTrace();
    } catch (IOException e){
        e.printStackTrace();
    }
 
     }
 
   }
 
   private void print_content(HttpsURLConnection con){
    if(con!=null){
 
    try {
 
       System.out.println("****** Content of the URL ********");            
       BufferedReader br = 
        new BufferedReader(
            new InputStreamReader(con.getInputStream()));
 
       String input;
 
       while ((input = br.readLine()) != null){
          System.out.println(input);
       }
       br.close();
 
    } catch (IOException e) {
       e.printStackTrace();
    }
 
       }
 
   }
}
