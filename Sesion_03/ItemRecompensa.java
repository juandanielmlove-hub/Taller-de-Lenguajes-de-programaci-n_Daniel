public abstract class ItemRecompensa {
    protected String nombre;
    protected int costoPuntos;
    public ItemRecompensa(String nombre, int costoPuntos) {
        this.nombre = nombre;
        this.costoPuntos = costoPuntos;
    }
    public abstract String descripcion();
    public void mostrar() {
        System.out.println(nombre + " (" + costoPuntos + " puntos): " + descripcion());
    }
}
