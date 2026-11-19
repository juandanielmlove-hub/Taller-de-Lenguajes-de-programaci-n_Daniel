import javax.swing.*;
import java.awt.*;

public class GameStoreLogin extends JFrame {
    private final JTextField usuario = new JTextField(18);
    private final JPasswordField clave = new JPasswordField(18);

    public GameStoreLogin() {
        super("GameStore Daniel | Acceso");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        JPanel panel = new JPanel(new GridLayout(3, 2, 12, 12));
        panel.setBorder(BorderFactory.createEmptyBorder(22, 22, 22, 22));
        panel.add(new JLabel("Usuario:")); panel.add(usuario);
        panel.add(new JLabel("Contraseña:")); panel.add(clave);
        JButton ingresar = new JButton("Ingresar");
        JButton limpiar = new JButton("Limpiar");
        ingresar.addActionListener(e -> {
            if (usuario.getText().trim().isEmpty() || clave.getPassword().length == 0) {
                JOptionPane.showMessageDialog(this, "Completa ambos campos.");
            } else {
                JOptionPane.showMessageDialog(this, "Bienvenido a GameStore Daniel, " + usuario.getText().trim());
            }
        });
        limpiar.addActionListener(e -> { usuario.setText(""); clave.setText(""); });
        panel.add(ingresar); panel.add(limpiar);
        add(panel); pack(); setLocationRelativeTo(null);
    }
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new GameStoreLogin().setVisible(true));
    }
}
