public class PrincipalPrueba {
    public static void main(String[] args) {
        ItemRecompensa[] catalogo = {
            new ItemAvatar("Avatar Nebulosa", 120),
            new ItemPaseAcademico("Pase Premium", 250)
        };
        for (ItemRecompensa item : catalogo) item.mostrar();
    }
}
