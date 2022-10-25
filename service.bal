import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/http;
import ballerina/log;
import ballerina/sql;

configurable int port = ?;
configurable string database = ?;
configurable string password = ?;
configurable string user = ?;
configurable string host = ?;

type output record {
    boolean valid;
    boolean isGuilty?;
    string charges?;
};

type Person record {
    string nic;
    @sql:Column {name: "isguilty"}
    int isGuilty;
    string charges?;
};

final mysql:Client mysqlEp = check new (host = host, user = user, password = password, database = database, port = port);

service / on new http:Listener(9090) {

    //function for checking the police records by nic
    isolated resource function get policeCheck/[string nic]() returns output|error? {
        Person|error queryRowResponse=mysqlEp->queryRow(`select * from police_details where nic=${nic.trim()}`);

        if queryRowResponse is error{
            output result={
                valid: false
            };

            log:printInfo("Invalid NIC");
            return result;
        }else{
            if queryRowResponse.isGuilty==0{
                output result={
                    valid: true,
                    isGuilty: false
                };
                log:printInfo(queryRowResponse.toBalString());
                return result;
            }else if queryRowResponse.isGuilty==1 {
                output result={
                    valid: true,
                    isGuilty: true,
                    charges:<string>queryRowResponse.charges
                };
                log:printInfo(queryRowResponse.toBalString());
                return result;
            }

        }
        return;
    }
}
