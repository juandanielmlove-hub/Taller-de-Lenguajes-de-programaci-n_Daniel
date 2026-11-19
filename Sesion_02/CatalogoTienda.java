import javax.swing.*;
import java.awt.*;

public class CatalogoTienda extends JFrame {
    public CatalogoTienda() {
        super("GameStore Daniel | Catálogo");
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLayout(new BorderLayout(12, 12));
        JLabel titulo = new JLabel("CATÁLOGO DE RECOMPENSAS", SwingConstants.CENTER);
        titulo.setFont(new Font("SansSerif", Font.BOLD, 20));
        add(titulo, BorderLayout.NORTH);
        JPanel productos = new JPanel(new GridLayout(2, 2, 12, 12));
        productos.setBorder(BorderFactory.createEmptyBorder(16, 16, 16, 16));
        agregar(productos, "Avatar digital", 120);
        agregar(productos, "Pase académico", 250);
        agregar(productos, "Insignia gamer", 90);
        agregar(productos, "Tema exclusivo", 180);
        add(productos, BorderLayout.CENTER);
        setSize(570, 380); setLocationRelativeTo(null);
    }
    private void agregar(JPanel panel, String nombre, int puntos) {
        JPanel tarjeta = new JPanel(new BorderLayout(5, 5));
        tarjeta.setBorder(BorderFactory.createTitledBorder(nombre));
        tarjeta.add(new JLabel(puntos + " puntos", SwingConstants.CENTER), BorderLayout.CENTER);
        JButton boton = new JButton("Seleccionar");
        boton.addActionListener(e -> JOptionPane.showMessageDialog(this, nombre + " seleccionado."));
        tarjeta.add(boton, BorderLayout.SOUTH); panel.add(tarjeta);
    }
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new CatalogoTienda().setVisible(true));
    }
}
