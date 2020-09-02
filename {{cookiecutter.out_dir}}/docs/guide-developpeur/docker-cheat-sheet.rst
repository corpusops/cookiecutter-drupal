Docker cheat sheet
^^^^^^^^^^^^^^^^^^

Toi développeur ou intégrateur qui t'es perdu ici, prends 5 minutes pour lire tout ça.

Docker
------

Démarrer les services
#####################

De bon matin, quand tu arrives au travail.

.. code-block:: sh

   ./control.sh up

Redémarrer les services
#######################

Quand ton réseau plante, et que tu as des erreurs du genre:

.. code-block:: sh

   An exception occurred in driver: SQLSTATE[08006] [7] could not translate hostname "db" to address: Name or service not known

Alors vite, lance :

.. code-block:: sh

   ./control.sh down
   ./control.sh up

Voir si les services tournent
#############################


.. code-block:: sh

   docker ps

Se connecter dans le docker qui contient Drupal
################################################

Pour lancer des commandes à la main à l'intérieur :

.. code-block:: sh

   ./control.sh userexec

Et si tu as envie de tout casser, tu peux le faire en root :

.. code-block:: sh

   ./control.sh shell

Utiliser la Drush dedans le docker
############################################

Commence par lui rentrer dedans:

.. code-block:: sh

   ./control.sh userexec

Puis:

.. code-block:: sh

   bin/drush <LA COMMANDE>

Par exemple :

.. code-block:: sh

   ./control.sh ./control.sh userexec bin/drush cr

Après une mise à jour
#####################

Ça les gens l'oublient assez vite, d'abord connecte toi dans ton docker :

.. code-block:: sh

   ./control.sh userexec

Puis, une fois à l'intérieur :

.. code-block:: sh

   bin/composerinstall

.. note::

   Attention à ne pas lancer la commande ``composer`` directement, le wrapper
   ``composerinstall`` va rajouter des options propres pour contourner des
   comportements de la distribution CentOS utilisée.

Sort vite de là, puis :

.. code-block:: sh

    ./control.sh userexec bin/post_update.sh

Base de données
---------------

Se connecter à pgsql
####################

Pour taper du SQL comme un fou :

.. code-block:: sh

   ./control.sh psql

Détruire et refaire sa base SQL (version docker)
################################################

Parce que ta base est pourrie !

.. code-block:: sh

   ./control.sh down
   docker volume remove aavant2local_postgresql
   ./control.sh up

Détruire et refaire sa base SQL (version barbue)
################################################

Se connecter à pgsql :

.. code-block:: sh

   ./control.sh psql

Puis une fois dedans :

.. code-block:: sql

   drop schema public cascade;
   create schema public;
