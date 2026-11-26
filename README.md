# Control de impuestos SII

App web para ingresar facturas electrónicas de compra y venta e importar el Registro de Compras y Ventas (CSV) o XML del SII, y calcular el F29 mensual (IVA, PPM, retenciones) y una estimación del impuesto anual.

- Sitio estático (un solo `index.html`), publicado con GitHub Pages.
- Datos e inicio de sesión en Supabase (tablas `sii_*`, ver `supabase/schema.sql`).
- Solo los correos en la tabla `sii_miembros` pueden ver y editar datos.

## Agregar una persona
En Supabase › SQL Editor:
```sql
insert into sii_miembros (email, nombre) values ('correo@ejemplo.cl', 'Nombre');
```

Los resultados son estimaciones y no reemplazan la revisión de un contador.
