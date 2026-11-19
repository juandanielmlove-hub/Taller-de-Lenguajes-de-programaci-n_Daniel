public class PrincipalEstudiante {
    public static void main(String[] args) {
        Estudiante estudiante = new Estudiante(1, "Daniel", 500);
        System.out.println("Antes: " + estudiante.resumen());
        estudiante.ganarPuntos(100);
        System.out.println("Canje de 250 puntos: " + estudiante.canjear(250));
        System.out.println("Después: " + estudiante.resumen());
    }
}
