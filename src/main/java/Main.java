import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Main {
    public static void main(String args[]) {
        insertPet("hund?", 3, "C6", null, null); // dog
        insertPet("dyr?", 3, null, null, null); // pet
        insertPet("cat?", 3, null, 6, null); // cat
        printAllPets();

    }

    private static void insertPet(String name, int age, String barkPitch, Integer lifeCount, String vetCVR) {
        Connection c = null;
        try {
            Class.forName("org.postgresql.Driver");
            c = DriverManager
                    .getConnection("jdbc:postgresql://localhost:5432/soft2021",
                            "softdb", "softdb");

            String sql = "CALL insert_pet(?, ?, ?, ?, ?);";
            PreparedStatement statement = c.prepareStatement(sql);
            statement.setString(1, name);
            statement.setInt(2, age);
            statement.setString(3, barkPitch);
            if(lifeCount != null) {
                statement.setInt(4, lifeCount);
            }
            else statement.setNull(4, java.sql.Types.INTEGER);
            statement.setString(5, vetCVR);


            statement.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getClass().getName()+": "+e.getMessage());
            System.exit(0);
        }
    }




    // Uses Read Only User Role
    private static void printAllPets() {
        Connection c = null;
        try {
            Class.forName("org.postgresql.Driver");
            c = DriverManager
                    .getConnection("jdbc:postgresql://localhost:5432/soft2021",
                            "bruger", "bruger");

            String sql = "SELECT * FROM PETS ORDER BY id;";
            PreparedStatement statement = c.prepareStatement(sql);
            try(ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    String type = "pet";

                    int id = result.getInt("id");
                    String name = result.getString("name");
                    int age = result.getInt("age");

                    String barkpitch = result.getString("barkpitch");

                    Integer lifeCount = result.getInt("lifecount"); //Returns 0 even if the value should be null
                    if (result.wasNull()) {
                        lifeCount = null;
                    }


                    if(barkpitch != null) type = "dog";
                    if(lifeCount != null) type = "cat";

                    System.out.println( id + " " + name + " " + type);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println(e.getClass().getName()+": "+e.getMessage());
            System.exit(0);
        }
    }

}

// CREATE ROLE bruger WITH
//    LOGIN
//            NOSUPERUSER
//    NOCREATEDB
//            NOCREATEROLE
//    INHERIT
//            NOREPLICATION
//	PASSWORD 'bruger';
//
//  GRANT SELECT ON ALL TABLES IN SCHEMA public TO bruger;
