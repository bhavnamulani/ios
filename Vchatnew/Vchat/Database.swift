import GRDB
import UIKit

// The shared database queue
var dbQueue: DatabaseQueue!

func setupDatabase(_ application: UIApplication) throws {
    
    // Connect to the database
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
    let databasePath = documentsPath.appendingPathComponent("db.sqlite")
    dbQueue = try DatabaseQueue(path: databasePath)
    
    dbQueue.setupMemoryManagement(in: application)
    
    // Use DatabaseMigrator to setup the database
    var migrator = DatabaseMigrator()
    migrator.registerMigration("MsgDatabase") { db in
        
        // Create a table
        try db.create(table: "Messages_Table") { t in
            // An integer primary key auto-generates unique IDs
            t.column("COL_MSG_BODY", .text)
            
            t.column("COL_FROM_USER", .text)
            
            t.column("COL_TO_USER", .text)
            
            t.column("COL_READ", .boolean)
            
            t.column("COL_SENT_BY", .text)
        }
        print("Message Table Create")
        
        // Create a table
        try db.create(table: "UserList_Table") { t in
            // An integer primary key auto-generates unique IDs
            t.column("COL_NAME", .text)
            
            t.column("COL_USERNAME", .text)
            
            t.column("COL_EMAIL", .text)
            
            t.column("COL_LAST_MESSAGE_RECEIVED", .text)
            
            t.column("COL_UNREAD_MSG_COUNT", .integer)
        }
        print("User Table Create")
    }
    
    try migrator.migrate(dbQueue)
    print("Tables Already Created")
}


func insertIntoUserTable(usersDoList: [UsersDo]){
    try! dbQueue.inDatabase { db in
        
        for user in usersDoList {
            
            let rows = try Row.fetchCursor(db,  "SELECT * FROM UserList_Table WHERE COL_USERNAME = ?", arguments:[user.username])
            while let row = try rows.next() {
                print(row.value(named: "COL_USERNAME"))
            }
            
            if checkIfUserExist(username:user.username!)
            {
            try db.execute(
                "INSERT INTO UserList_Table (COL_NAME, COL_USERNAME, COL_EMAIL, COL_LAST_MESSAGE_RECEIVED, COL_UNREAD_MSG_COUNT) VALUES (?,?,?,?,?)",
                arguments: [user.name, user.username, user.email, user.lastMessageReceived, user.unReadMsgCount])
            print ("Insert_Users>>", user.name!)
            }
            
        }
        
    }
}

func checkIfUserExist(username:String)-> Bool{
    try! dbQueue.inDatabase { db in
        let rows = try Row.fetchCursor(db,  "SELECT * FROM UserList_Table WHERE COL_USERNAME = ?", arguments:[username])
        while let row = try rows.next() {
            print(row.value(named: "COL_USERNAME"))
        }
    }
    return true
}


func getUsersFromTable() -> [UsersDo] {
    var usersDoList:[UsersDo] = []
    
    try! dbQueue.inDatabase { db in
        
        let rows = try Row.fetchCursor(db, "SELECT * FROM UserList_Table")
        while let row = try rows.next() {
            
            let name: String? = row.value(named: "COL_NAME")
            let username: String? = row.value(named: "COL_USERNAME")
            let email: String? = row.value(named: "COL_EMAIL")
            let lastMessageReceived: String? = row.value(named: "COL_LAST_MESSAGE_RECEIVED")
            let unReadMsgCount: Int? = row.value(named: "COL_UNREAD_MSG_COUNT")
            
            var user: NSDictionary = ["name": name, "username":username, "email":email, "lastMessageReceived":lastMessageReceived, "unReadMsgCount":unReadMsgCount]
            
            let userDo = UsersDo(json: user as NSDictionary)
            usersDoList.append((userDo))
            print("Get Users List" , usersDoList.count)
        }
    }
    return usersDoList
}

func insertIntoMsgTable(messagesDo:MessagesDo){
    try! dbQueue.inDatabase { db in
        try db.execute(
            "INSERT INTO Messages_Table (COL_MSG_BODY, COL_FROM_USER, COL_TO_USER, COL_READ, COL_SENT_BY) VALUES (?, ?,?,?,?)",
            arguments: [messagesDo.msgText, messagesDo.fromUser, messagesDo.toUser, messagesDo.read, messagesDo.sentBy as? DatabaseValueConvertible])
        _ = db.lastInsertedRowID
        
        print ("Insert_Msgs>>",messagesDo.msgText!)
    }
}

func getMessagesFromTable() -> Array<MessagesDo>{
    var msgsDoList = Array<MessagesDo>()
    
    try! dbQueue.inDatabase { db in
        let rows = try Row.fetchCursor(db,  "SELECT * FROM Messages_Table WHERE COL_FROM_USER = ? OR COL_TO_USER = ?", arguments:[1,2])
        while let row = try rows.next() {
            var msgsDo:MessagesDo!
            msgsDo = MessagesDo()
            let msgBody: String? = row.value(named: "COL_MSG_BODY")
            let fromUser: String? = row.value(named: "COL_FROM_USER")
            let toUser: String? = row.value(named: "COL_TO_USER")
            let read: String? = row.value(named: "COL_READ")
            let sentBy: String? = row.value(named: "COL_SENT_BY")
            
            print("msgBody",msgBody)
            print("fromUser",fromUser)
            print("toUser",toUser)
            print("read",read)
            print("sentBy",sentBy)
            
            msgsDoList.append(msgsDo)
            print("GetMessages: ",msgsDoList.count)
        }
    }
    
    return msgsDoList
}


