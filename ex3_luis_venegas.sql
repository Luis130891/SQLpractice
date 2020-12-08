host cls
PROMPT ============================================================================================
PROMPT Luis Veneagas Ulloa 
PROMPT ============================================================================================

PROMPT ..............
PROMPT Se conecta como system, dropea usuario exa3, lo vuelve a crear (permisos de dba) y se conecta con exa3
PROMPT crea la tabla, PK y secuencia... todo listo para que programen lo que se solicita!
PROMPT (2 puntos menos si no coloca su nombre completo (horario ya apacere), al inicio y al final del script) (Maximo a rebajar 4ptos)

PROMPT Solo 4 objetos por crear (Procedimiento, Trigger, Vista y Funcion) Uno de cada uno!
PROMPT NO DEBE CREAR FUNCIONES ADICIONALES la validacion del procedimiento y/o trigger debe hacerla alli mismo!
PROMPT puede usar todas las herramientas vistas en las clases (funciones estandar, excepciones, cursores, AR, select into.. etc)
PROMPT ..............

PROMPT OJO QUE NO MODIFIQUEN NADA de las pruebas ni datos que se insertan!!... se actualizan!! o se borran!! (puntos menos!)
PROMPT NO MODIFICAR NADA DE LOS NOMBRES DE : tabla, procedimiento, funcion, vista, trigger. (Dejar esos nombres!)
PROMPT Solo construir el codigo solicitado que complete las acciones, y ver los ejemplos y soluciones, todo claro!!

PROMPT ..............ENTREGABLE!
PROMPT Nombre del archivo ex3_nombre_apellido.sql (todo minuscula sin tildes ni caracteres especiales)
PROMPT 1 hora 20 minutos de programacion (como toman unos 20 minutos para ver los videos se les da 1h 40 minutos en total!)
PROMPT cada minuto adicional de atraso, se rebaja 1 punto.
PROMPT Estudiantes que tengan adecuacion tienen 1h mas.

PROMPT HACER EL EXAMEN INDIVIDUAL, SIN CONSULTAR INTERNET NI OTROS ESTUDIANTES,
PROMPT Claro, si pueden usar todos los scripts de ejemplo y tareas morales!
PROMPT Apelo a la honestidad y honorabilidad de cada estudiante!! OK! de acuerdo!!!
PROMPT Inicio Base .............

conn system/admin

drop user exa3 cascade;
create user exa3 identified by exa123;
grant dba to exa3;

conn exa3/exa123

PROMPT Creacion de Tabla de Choferes
create table choferes(
id          number(4)    not null,
nombre      varchar2(10) not null,
fec_ingreso date         not null,
salario     number(6)    not null
);

PROMPT Crear PK de Tabla de Choferes
alter table choferes add constraint choferes_pk primary key (id);

PROMPT Crear Secuencia de Tabla de Choferes
create sequence sec_id_chofer start with 10 increment by 1;

PROMPT ***NUEVO. Define el formato de la fecha detallado (solo para diferenciar) ** NO CAMBIAR!
alter session set nls_date_format='dd-mm-yyyy hh24:mi';

PROMPT Fin base .............
PROMPT ..............



PROMPT ============================================================================================
PROMPT 1) 8pm (30ptos) Crear procedimiento (prc_ins_chofer) que inserte en tabla choferes. Si el nombre ya existe genere
PROMPT un mensaje de error (y no debe insertar) no se permite si esta registrado JUAN, y mete Juan (cuenta como repetido!)
PROMPT no es error de validacion de PK, es una validacion propia antes de insertar en el procedimiento!
PROMPT Recordar que el ID se genera por secuencia (no se pasa por parametro) y el ID es PK.

create or replace procedure prc_ins_chofer(PNombre in varchar2, PFec_ingreso in varchar2, PSalario in number) is
  
VName1  varchar2(10);
begin
 select  nombre  into VName1 from choferes
 where upper(nombre)= upper(PNombre);
 
if VName1 is not null then
 raise_application_error(-20001,' Nombre de Chofer repetido, no se puede insertar');
end if;
exception
when no_data_found   then
insert into choferes(id,nombre,fec_ingreso,salario) 
values(sec_id_chofer.NEXTVAL,PNombre,PFec_ingreso,PSalario);
commit;

end prc_ins_chofer;
/
show error

PROMPT NO DEBE CREAR FUNCIONES ADICIONALES la validacion del procedimiento debe hacerla alli mismo!

PROMPT ============================================================================================
PROMPT 2) 8pm (30ptos) Crear trigger que no permita aumentar el salario si la persona ingreso a trabajar en el anio 2020 
PROMPT (desde 01-enero-2020 hasta la fecha) solo se permite si es del anio 2019 para atras (31-dic-2019 habia atras...)
PROMPT Puede validar QUEMADO anio 2020, o bien obtener anio actual con sysdate (para este ejemplo cualquiera de las dos opciones)
PROMPT si cambia nombre o rebaja salario no hay problema, se puede hacer. Es solo bloquear el AUMENTO de SALARIO
PROMPT NO USAR TABLA DE PARAMETROS.
create or replace trigger chofer_trg_bur before update on choferes
referencing old as old new as new
for each row
declare
begin
	if  extract(year from :old.fec_ingreso) >= 2020 and :old.salario < :new.salario then
	raise_application_error(-20001,'No se puede aumentar');
END IF;
end chofer_trg_bur;
/
show error

PROMPT ============================================================================================
PROMPT 3) 8pm (15ptos) Crear vista que muestre la informacion como se mira en la prueba del select de la vista
PROMPT que es: ID + Fecha Ingreso + Nombre + Salario (Exacto con los parentesis y guiones que aparecen)
PROMPT tambien el orden exacto como aparece!
create view rep_detalle as 
select (id||'('||TO_CHAR(fec_ingreso,'dd-mm-yyyy')||')'||'-'||nombre||'-'||salario)DATO
from choferes;



PROMPT ============================================================================================
PROMPT 4) 8pm (25ptos) Crear funcion que cuente los choferes que tengan el PNombre o el PSalario indicado (cualquiera de los dos)
PROMPT Entonces cuenta los que cumplan uno (nombre exacto) o bien el otro criterio (salario) VER LOS EJEMPLOS ABAJO!
create function fun_contar(PNombre in varchar2, PSalario in number) return number is
  VName number;
begin
select  count(*)
  into    VName
  from  choferes c where c.nombre=PNombre or c.salario=PSalario ;
  return (VName);
end fun_contar;
/
PROMPT ============================================================================================
PROMPT ============================================================================================
PROMPT PRUEBAS, Verifican la correcta programacion de los requerimientos solicitados
PROMPT Los resultados deben dar exactos, estan colocados en un orden para afectar lo menos en caso 
PROMPT que no resuelvan algun ejercicio. 
PROMPT Deben respetar el orden y valores de las pruebas NO CAMBIAR NADA!!
PROMPT si programan todo ok, debe dar los mismos resultados
PROMPT ============================================================================================
PROMPT ============================================================================================
PROMPT Ejecuta el llamado al procedimiento 4 veces, uno con error, quedan 3 choferes ID: 10,11,12.
PROMPT ..............
--Base brindar
PROMPT Juan #10 (correcto se inserta)
exec prc_ins_chofer('Juan',to_date('28-12-2019','dd-mm-yyyy'),1400);

PROMPT ..............
PROMPT OJO: Si no logra hacer la validacion comente esta linea para que tenga los 3 registros para el resto de pruebas
PROMPT (Error esperado #1) (no se gasta secuencia) porque procedimiento valida antes de insertar!
exec prc_ins_chofer('JUAN',to_date('30-12-2019','dd-mm-yyyy'),1300);

PROMPT ..............
PROMPT Ana #11 (correcto se inserta)
exec prc_ins_chofer('Ana',to_date('20-06-2020','dd-mm-yyyy'),1400);

PROMPT ..............
PROMPT Vera #12 (correcto se inserta)
exec prc_ins_chofer('Vera',to_date('21-06-2020','dd-mm-yyyy'),1040);

 PROMPT ..............
 PROMPT Tres Choferes
 select * from choferes;

PROMPT como ven no se salta el SECUENCE, quedan ID 10,11 y 12

PROMPT ============================================================================================
PROMPT Consultar la Vista
--Base brindar
select * from rep_detalle order by 1;

PROMPT ============================================================================================
-- Base brindar prueba funcion con los valores originales
 PROMPT Probar la funcion con Vera o 1040 (solo hay uno) pues es la misma condicion para ambos
 PROMPT ..............
 select fun_contar('Vera',1040) cantidad from dual;

 PROMPT ..............
 PROMPT Probar la funcion con Ana o 1040 (son dos registros) 
 select fun_contar('Ana',1040) cantidad from dual;

 PROMPT ..............
 PROMPT Probar la funcion con Vera o 1400 (son tres registros) 
 select fun_contar('Vera',1400) cantidad from dual;
 PROMPT ============================================================================================
--Base brindar
PROMPT Probar los UPDATE y el TRIGGER
 PROMPT ID #10 Si permite (anio 2019) Juan actualizar salario a 1450
 update choferes set salario = 1450 where id = 10;
 commit;
 PROMPT ..............

 PROMPT (Error esperado #2)  No permite aumentar salario a 1600 por trigger del (anio 2020) Ana #11
 update choferes set salario = 1600 where id = 11;
 commit;
 PROMPT ..............

 PROMPT ID #11 Ana Si permite cambiar nombre de Ana a Anita (pues no aumenta el salario)
 update choferes set nombre = 'Anita' where id = 11;
 commit;
 PROMPT ..............

 PROMPT Tambien a ID #11 permite rebajar el salario de 1400 a 1300 (a Anita)
 update choferes set salario = 1300 where id = 11;
 commit;
 PROMPT ..............

 PROMPT Registros Finales
 select * from choferes;


 PROMPT ============================================================================================
 PROMPT Luis Venegas Ulloa
 PROMPT ============================================================================================

