.. _developpeur-front:

Guide du développeur front
!!!!!!!!!!!!!!!!!!!!!!!!!!

Introduction
============

Les *assets* pour le code Javascript front-end sont générée à l'aide de
**@symfony/webpack-encore**. C'est une outil d'auto-configuration de *webpack*
développé par la communauté Symfony, qui peut être utilisé en dehors de Symfony
ce qui est le cas ici.

Générer les assets
==================

En mode développement
---------------------

C'est aussi simple que:

.. code-block:: sh

   # Aller dans le répertoire du projet
   cd /path/to/projet

   # Il faut être dans le répertoire de l'application
   cd app

   yarn dev

.. note::

   Vous n'aurez jamais besoin de supprimer le répertoire ``app/public/build`` à
   la main, *webpack* est configuré pour et le fait automatiquement.

En mode production
------------------

C'est aussi simple que:

.. code-block:: sh

   # Aller dans le répertoire du projet
   cd /path/to/projet

   # Il faut être dans le répertoire de l'application
   cd app

   yarn build

Mode "watch"
============

C'est aussi simple que:

.. code-block:: sh

   # Aller dans le répertoire du projet
   cd /path/to/projet

   # Il faut être dans le répertoire de l'application
   cd app

   yarn watch

.. note::

   Il est recommandé de l'arrêter et de le relancer de temps en temps, surtout
   si vous travailler sur Mac et que vous utilisez un mécanisme de synchronisation
   de fichiers entre votre machine et docker. Certaines modifications avec certains
   systèmes de fichiers peuvent parfois ne pas être vues par webpack.

.. warning::

   Si vous êtes sur une machine Apple ou avec MacOS, pensez à consulter
   la :ref:`documentation de cette plateforme <apple-de-la-mort>`.

Versionner les assets
=====================

**Les assets distribuables générés sont versionnés avec le code source de**
**l'application**, afin de ne pas avoir à utiliser node ou yarn sur les
environnements cibles.

Pour versionner les assets à distribuer, vous devez donc utiliser git:

 - sur la branche **master**, les assets générés sont en mode **dev**, ce qu'il
   veut dire qu'ils sont à la fois très gros, mais aussi plus lent car ils
   contiennent des outils de debug,

 - sur les branches **stable-x.y** ils sont en mode **build**, c'est à dire
   prêt à l'utilisation en production, minifiés et optimisés.

Pour les branches de développement
----------------------------------

.. code-block:: sh

   cd /path/to/projet
   git co master # ou toute autre branche
   cd app/

   yarn dev

   git add -f public/build
   git commit -m "Generated assets"

Pour les branches de production
-------------------------------

.. code-block:: sh

   cd /path/to/portailweb
   git co stable-x.y # ou toute autre branche
   cd app/

   yarn build

   git add -f public/build
   git commit -m "Generated production assets"

.. note::

   Vous noterez que les noms de fichiers des assets générés pour la production
   contiennent un hash basé sur le contenu des dits fichiers, le git add ici
   va donc créér beaucoup de bruit, c'est normal.
