public class Estudiante {
    private final int id;
    private String nombre;
    private int puntos;
    public Estudiante(int id, String nombre, int puntos) {
        this.id = id; this.nombre = nombre; this.puntos = Math.max(0, puntos);
    }
    public void ganarPuntos(int cantidad) {
        if (cantidad > 0) puntos += cantidad;
    }
    public boolean canjear(int costo) {
        if (costo <= 0 || costo > puntos) return false;
        puntos -= costo; return true;
    }
    public String resumen() { return id + " | " + nombre + " | " + puntos + " puntos"; }
}
