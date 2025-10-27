import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Main {
    public static void main(String[] args) {


        String url = "jdbc:postgresql://localhost:5432/testdb";
        String user = "postgres";
        String password = "botbot02";

        System.out.println("Проверяем подключение к PostgreSQL...");

        try (Connection connection = DriverManager.getConnection(url, user, password)) {
            if (connection != null) {
                System.out.println("Подключение успешно!");
            } else {
                System.out.println("Подключение не удалось (connection == null)");
            }
        } catch (SQLException e) {
            System.out.println("Ошибка подключения: " + e.getMessage());
        }
    }
}
