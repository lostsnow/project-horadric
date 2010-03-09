import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

import org.phprpc.*;
import org.phprpc.util.*;

interface User {
    public void authInfo(String api_name, String api_key);
    public Object getUserSimpProfile(Object user_name);
}

public class UserInfoClient {
    public static void main (String [] args) {
        final PHPRPC_Client client = new PHPRPC_Client ("http://api.hanmei.com/user.php");
        final User usr = (User) client.useService(User.class);
//        client.setKeyLength(32);
//        client.setEncryptMode(2);

        usr.authInfo("hanmei", "59RMSIGN1G1461QCKS4Y6K2Q");

        if (args.length == 0) {
            System.out.println("EMPTY_USER");
        } else {
            Object[] uname = new Object[1];
            uname[0] = args[0];
            Object o = usr.getUserSimpProfile(uname[0]);
            if(o instanceof AssocArray){
//                try {
                    AssocArray arr = (AssocArray) o;
                    HashMap ht = arr.toHashMap();
                    Iterator iterator = ht.entrySet().iterator();
                    while (iterator.hasNext()) {
                        Map.Entry entry = (Map.Entry) iterator.next();
                        System.out.print(entry.getKey());
                        System.out.print(":");
                        System.out.println(Cast.toString(entry.getValue()));
                    }
//                } catch (ClassCastException e) {
//                    e.printStackTrace();
//                }
            }else if (o instanceof byte[]) {
                System.out.println(Cast.toString(o));
            } else {
                System.out.println("SERVER_ERR");
            }
        }
    }
}

//Output:
//id:58827
//user_name:lostsnow
//nickname:断桥残雪
//avatar:http://static.hanmei.com/avatars/Profiles.gif
//homepage:http://www.hanmei.com/home.php?user=58827