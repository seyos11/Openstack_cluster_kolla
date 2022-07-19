





Es importante realizar un apaño en el despleigue de Openstack para evitar conflictos de red. El conflicto se produce al incorporar como red de proveedor la red que es utilizada habitualmente para la conectividad con internet. En muchos proyectos va resultar esencial disponer de una red externa que habitlite la comunicación con el exterior a las máquinas virtuales desplegadas. En este caso, siempre se usa la red del departamento (138.4.7.128/25) para dicha comunicación. 

El problema surge cuando en el archivo globals se marca con una variable la serie de puertos/interfaces que se desea que establezcan las redes de proveedor. Entre estas interfaces se encuentra eth4 que es la que tiene el cable ethernet al roouter de la red del departamento. En un momento del despliegue del clúster de Openstack está interfaz se inhabilita. Esto produce que en una serie de instrucciones a tomar psoteriomente a esta inhabilitación no se tenga acceso a internet, desencadenando una serie de fallos en el despliegue que lo interrumpen.

Al no disponer de otra conexión a Internet se toma la siguiente manipulación en la conexión de las máquinas de Openstack. En todos los nodos de Openstack se ha de configurar la ruta IP por defecto para que el camino a internet se haga a través de la interfaz de gestión. Es decir, se toma en este caso la interfaz eth1, que es la que conecta los dispositivos con la red de gestión empleada para el despleigue de ansible a través de ssh. Esta red ha de comunicarnos con otro dispositivo en al misma red (como el nodo OSM o el nodo cliente) que esté conectado a su vez a la red del departamento. Además, se ha de comrpobar que dichos nodos tienen la opción de routing activada ('net.ipv4.ip_forward=1') y activar un NAT (usando el fichero creado por David de vnx_config_nat) para poder establecer dicha transformación y dar conectividad a los nodos a través de la red de gestión.

Una vez hecha esta manipulación, los nodos disponen de conectividad a internet durante el despliegue permitiendose la finalización de dicho proceso. Una vez desplegado, las instancias virtuales van a poder ser conectadas a la red de proveedor del departamento  y tener acceso externo.

Uno de los escenarios clásicos es la generación de una red externa en Openstack que disponga de un pool de direcciónes IP dentro del rango del departamento y, mediante el uso de un router y direcciones IP flotantes, se conecte a una red de autoservicio donde se desplieguen las instancias. Esto permite una capa de jerarquía y seguridad mayor, donde para acceder a las instancias se hace uso de direcciones IP flotantes mapeadas las direcciones IP de la red de autoservicio adjuntas a cada instancia virtual.

En el caso de la red del departamento es importante tener en cuenta que direcciones IP son escogidas para el pool. Al haber pocos rangos, se toma uno de tamaño mínimo (138.4.7.216-138.4.7.218) para poder realizar las pruebas necesarias.

Una cosa que sorprende es el retardo introducido al realizar conexión con la instancia a través de la IP flotante. Es algo que habría que investigar con un nivel de detalle mayor. El traceroute tampoco funciona como cabría de esperar, ya que a pesar de que el ttl mostrado en el ping es de 63 (se baja uno debido al router).


En la imagen mostrada a continuación se representa la topología de red de Openstack, en las cuales se observa el escenario comentado, además de una red extra vlan.

Las redes de proveedor pueden disponer de un servicio de etiquetado VLAN. En este caso, el acceso es directo. Para ello es indispensable que las máquinas que intenten comunicarse con estas instancias virtuales estén en el mismo rango de direcciones IP, hagan uso de la misma etiqueta seleccionada para la red y esten conectados directa o indirectamnte a la misma red física. En nuestro caso se toma la interfaz eth3 para el acceso a la red de proveedor VLAN; los dispostiivos que quieran conectarse con esta red deberán tener conexión física con esta interfaz. En nuestro caso, se utiliza un switch físico que agrega todas las redes del clúster del departamento además del nodo cliente encargado de la generación de escenarios simulados. Al final, de forma indirecta, todas las instancias virtuales generadas en estos escenarios tendrán conectividad a nivel 2 con la red vlan de proveedor.


![Alt text](./topologiaRed.png?raw=true "Topología")









En el nodo controlador implementar el siguiente comando si ya se ha realizado el bootstrap-servers con error. Esto genera un perfil de libvirt que es eliminado de primeras y que es necesario tener creado para que la tarea de ansible no se interrumpa. En teoría está solucinado en la versión utilizada, ya que comprueba el perfil antes de eliminarlo, pero da error de que no existe:
De momento las pruebas de Openstack se están realizando con un nodo, lo que implica que Kubespray debe funcionar con un solo worker también. Esto es así porque se generan conflictos de docker cuando se realizan las configuraciones de kolla. 



```
sudo apparmor_parser  /etc/apparmor.d/usr.sbin.libvirtd
```

Por otro lado en docker hay que crear un fichero de configuración para que no salte un error en el servicio.  El fichero es el siguiente:/etc/systemd/system/docker.service.d/docker.conf

El contenido de dicho fichero debe ser el mostrado a continuación

```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd

```


Finalmente, la receta a seguir sería la instalación encontrada en el README.md de vnx-kolla de openstack.
