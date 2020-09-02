.. _apple-de-la-mort:

Travailler avec MacOS
!!!!!!!!!!!!!!!!!!!!!

.. warning::

   (et c'est pas un cadeau).

MacOS dipose d'un excessivement mauvais support de docker, son système
de fichier partagé est extrêmement lent de par le fait qu'il passe par
une machine virtuelle intermédiaire dans laquelle Linux est installé.

Le projet dispose donc de quelques manoeuvres de contournement à maîtriser.

Syncho des fichiers
===================

Lorsque vous effectuez des modifications sur vos fichiers, source, assets
front générés ou autres, vous devez lancer à la main un script, systématiquement,
qui déploie en utilisant ``rsync`` les fichiers dans les conteneurs:

.. code-block:: sh

   ./control.sh osx_sync

.. warning::

   Quand on dit systématiquement, il faut le faire.
