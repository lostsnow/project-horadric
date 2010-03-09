import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

import org.phprpc.*;
import org.phprpc.util.*;

interface Friend {
    public void authInfo(String api_name, String api_key);
	public Object getUserFriendsId(Object user_name);
}

public class UserFriendsClient {
    public static void main (String [] args) {
        final PHPRPC_Client client = new PHPRPC_Client ("http://api.hanmei.com/user.php");
        final Friend friend = (Friend) client.useService(Friend.class);
//        client.setKeyLength(32);
//        client.setEncryptMode(2);

        friend.authInfo("hanmei", "59RMSIGN1G1461QCKS4Y6K2Q");

        if (args.length == 0) {
            System.out.println("EMPTY_USER");
        } else {
            Object[] uname = new Object[1];
            uname[0] = args[0];
            Object o = friend.getUserFriendsId(uname[0]);
            if(o instanceof AssocArray){
//                try {
                    AssocArray arr = (AssocArray) o;
                    int n = arr.size();

                    for (int i = 0; i < n; i++) {
                        Object result = (Object)Cast.cast(arr.get(new Integer(i)), Object.class);
                        AssocArray arr2 = (AssocArray) result;
                        HashMap ht = arr2.toHashMap();
                        Iterator iterator = ht.entrySet().iterator();
                        while (iterator.hasNext()) {
                            Map.Entry entry = (Map.Entry) iterator.next();
                            System.out.println(Cast.toString(entry.getValue()));
                        }
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
//G:\java>java UserFriendsClient lostsk
//58827
//11775
//38
//518452