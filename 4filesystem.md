#�t�@�C���V�X�e���̊Ǘ�

## �A�N�Z�X���̊Ǘ�
Linux��POSIX�Ŏ�����Ă���A�N�Z�X����ɏ������Ă��܂��BPOSIX�Ƃ́uPortable Operating System Interface for UNIX�v�̗��ŁAIEEE�iInstitute of Electrical and Electronics Engineers�A�A�C�E�g���v���E�C�[�j�ɂ���Ē�߂�ꂽ�AUNIX�x�[�X��OS�̎d�l�Z�b�g�ł��B���[�U�[ID�iuid�j/�O���[�vID�igid�j�ƃp�[�~�b�V�����̑g�ݍ��킹�Ńt�@�C���ɑ΂���A�N�Z�X�����Ǘ����Ă��܂��B

### UID��GID
���[�U�[ID�iuid�FUser Identifier)��Linux�V�X�e���Ń��[�U�[�����ʂ��邽�߂̃��j�[�N�Ȕԍ��ł��BLinux�Œǉ����ꂽ���[�U�[�J�E���g�ɂ́A���ꂼ��ʂ�uid������U���܂��B
uid��0����65535�܂ł̒l���Ƃ�܂��B0�͓��ʂȃ��[�U�[ID�ŁA�Ǘ��Ҍ���������root���[�U�[�ɕt�^����Ă��܂��B

�O���[�vID�igid: Group Identifier�j�̓O���[�v�����ʂ��邽�߂̃��j�[�N�Ȕԍ��ł��BLinux�̃��[�U�[�́A1�ȏ�̃O���[�v�ɏ������邱�Ƃ��ł��܂��B
gid��0����65535�܂ł̒l���Ƃ�܂��B

### ���ؗp���[�U�[�A�O���[�v�̊m�F
�A�N�Z�X����̓���m�F�̂��߁A���ؗp�̃��[�U�[��p�ӂ��܂��B���łɃ��[�U�[suzuki�͍쐬���Ă���̂ŁA���[�U�[sato��ǉ����܂��B



```
$ sudo useradd sato
$ id sato
uid=1004(sato) gid=1004(sato) groups=1004(sato)
$ id suzuki
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki),5001(power)
```

### �ʁX�̃��[�U�[�Ƃ��č�Ƃ���
���[�U�[sato�ƃ��[�U�[suzuki �ł̑�����X���[�Y�ɍs�����߁A���ꂼ��ʁX�̃��[�U�[�Ń��O�C�����܂��B

Linux�T�[�o�[�Ƃ͕ʂ̒[������SSH�Ń����[�g���O�C�����đ�����s���Ă���ꍇ�ɂ́A���ꂼ��̃��[�U�[�Ń����[�g���O�C�����܂��B

Linux�T�[�o�[���GUI�ő�����s���Ă���ꍇ�ɂ́A�K���ȃ��[�U�[�Ń��O�C��������A�ʁX�̃^�[�~�i�����N�����Asu�R�}���h���g���ă��[�U�[��؂�ւ���Ƃ悢�ł��傤�B


�^�[�~�i��A�Ń��[�U�[suzuki�ɐ؂�ւ��܂��B

```
$ sudo su - suzuki
$ id
uid=1001(suzuki) gid=1001(suzuki) groups=1001(suzuki),5001(power) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

�^�[�~�i��B�Ń��[�U�[sato�ɐ؂�ւ��܂��B

```
$ sudo su - sato
$ id
uid=1004(sato) gid=1004(sato) groups=1004(sato) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023```

### �v���Z�X�̎��s���̊Ǘ�
Linux�ł́Aroot���[�U�[�������đ��̃��[�U�[���N�������v���Z�X���~�����邱�Ƃ͂ł��܂���B

�ȉ��̗�ł́A���[�U�[sato��vi�G�f�B�^�ivim�j���N������/tmp�Ƀt�@�C�����쐬���悤�Ƃ��Ă���v���Z�X�����[�U�[suzuki��kill�R�}���h�Œ�~���悤�Ƃ��܂����A��~�ł��܂���B


���[�U�[sato��vi�G�f�B�^��/tmp/sato���쐬���܂��B

```
[sato@vbox ~]$ vi /tmp/sato
```

���[�U�[suzuki��vim�v���Z�X���m�F���܂��B

```
[suzuki@vbox ~]$ ps aux | grep vim
sato        2351  0.0  0.5 229720  9472 pts/1    S+   18:15   0:00 /usr/bin/vim /tmp/sato
suzuki      2355  0.0  0.1 221676  2304 pts/0    S+   18:15   0:00 grep --color=auto vim
```

���[�U�[suzuki�����[�U�[sato�����s����vim�G�f�B�^�̃v���Z�X��kill�R�}���h�Œ�~���悤�Ƃ��܂����A��~�ł��܂���B�w�肷��v���Z�XID�́Aps�R�}���h��2�Ԗڂ̕\�����ڂł��B

```
[suzuki@vbox ~]$ kill 2351
-bash: kill: (2351) - ������Ă��Ȃ�����ł�
```

���[�U�[sato�́A�G�f�B�^�Łusato�v�ƋL�q���A�u:wq�v�Ɠ��͂���vim�G�f�B�^���I�����܂��B

### �t�@�C���̃A�N�Z�X���̊Ǘ�
���[�U�[sato���쐬�����t�@�C��/tmp/sato���g���āA�A�N�Z�X���̓�������؂��܂��B

���[�U�[sato�Ńt�@�C��/tmp/sato�̃A�N�Z�X�����m�F���܂��B���̑��̃��[�U�[�ւ̃A�N�Z�X���͓ǂݎ��̂ݗ^�����Ă��܂��B

```
[sato@vbox ~]$ ls -l /tmp/sato
-rw-r--r--. 1 sato sato 5  7�� 26 18:17 /tmp/sato
```

���[�U�[suzuki��cat�R�}���h�����s���A�t�@�C��/tmp/sato�̓��e���m�F���܂��B���̑��̃��[�U�[�ւ̓ǂݎ��͋�����Ă���̂ŁA���e���m�F�ł��܂��B

```
[suzuki@vbox ~]$ cat /tmp/sato
sato
```

���[�U�[suzuki�Ńt�@�C��/tmp/sato�ɒǋL���Ă݂܂��B�������݂̃A�N�Z�X���͗^�����Ă��Ȃ��̂ŃG���[�ƂȂ�܂��B

```
[suzuki@vbox ~]$ echo "suzuki" >> /tmp/sato
-bash: /tmp/sato: ��������܂���
```

### umask�ƃf�t�H���g�̃p�[�~�b�V�����̊֌W
umask�Ƃ́A�t�@�C����f�B���N�g�����V�K�ɍ쐬�����ۂɃf�t�H���g�̃p�[�~�b�V���������肷�邽�߂̒l�ł��Bumask�R�}���h�Ŋm�F�ł��܂��B

```
[sato@vbox ~]$ umask
0022
```

umask�̐ݒ�l�ɂ́A�V�����t�@�C�����쐬����ۂɐݒ肵�Ȃ��i�����Ȃ��j�p�[�~�b�V������8�i���Ŏw�肵�܂��B

| | �ǂݎ�� | �������� | ���s |
|-------|-------|-------|-------|
| �p�[�~�b�V���� | r | w | x |
| 8�i���l | 4 | 2 | 1 |

�t�@�C���ƃf�B���N�g���ł͐ݒ肳���f�t�H���g�̃p�[�~�b�V�������ς��̂ŁA���ꂼ��m�F���Ă݂܂��傤�B

### �t�@�C���쐬�̃p�[�~�b�V������umask
�t�@�C�����V�K�쐬�����ۂɂ̓t�@�C���̎��s�p�[�~�b�V����(eXecute)�͐ݒ肵�Ȃ��̂ŁA0666(rw-rw-rw-)�ɑ΂���umask�̒l���K�p����܂��B

umask��0022�Ɛݒ肳��Ă���ƁA�O���[�v�Ƃ��̑��̃��[�U�[�̏������݂̃p�[�~�b�V�����iw�j���ݒ肳��Ă��Ȃ��t�@�C���i-rw-r--r--�A0644�j���쐬����܂��B

```
[sato@vbox ~]$ umask
0022
[sato@vbox ~]$ touch testfile
[sato@vbox ~]$ ls -l testfile
-rw-r--r--. 1 sato sato 0  7�� 26 18:19 testfile
```

### �f�B���N�g���쐬�̃p�[�~�b�V������umask
�f�B���N�g�����V�K�쐬�����ۂɂ́A���s�p�[�~�b�V����(eXecute)���K�v�ɂȂ�̂ŁA0777(rwxrwxrwx)�ɑ΂���umask�̒l���K�p����܂��B���s�p�[�~�b�V�������K�v�ɂȂ�̂́A1�͂ł����������Ƃ���A���̃f�B���N�g�����J�����g�f�B���N�g���ɂ��邽�߂ɂ͎��s�p�[�~�b�V�������K�v�ɂȂ邩��ł��B

umask��0022�Ɛݒ肳��Ă���ƁA�O���[�v�Ƃ��̑��̃��[�U�[�̏������݂̃p�[�~�b�V�����iw�j���ݒ肳��Ȃ��f�B���N�g���i-rwxr-xr-x�A0755�j���쐬����Ă��܂��B

```
[sato@vbox ~]$ umask
0022
[sato@vbox ~]$ mkdir testdir
[sato@vbox ~]$ ls -ld testdir
drwxr-xr-x. 2 sato sato 6  7�� 26 18:20 testdir
```

### umask��4���̗��R
�p�[�~�b�V�����͒ʏ�A���[�U�[�A�O���[�v�A���̑��̃��[�U�[��3�ɑ΂���A�N�Z�X�����ݒ肳��܂����Aumask�̒l��4���ɂȂ��Ă��܂��B����́A�ʏ�̃p�[�~�b�V�����̐擪�ɁAsetUID/setGID/�X�e�B�b�L�[�r�b�g��\�������܂܂�邽�߂ł��BsetUID�Ȃǂɂ��Ă͌�q���܂��B
�܂��A�ʏ�setUID�Ȃǂ��f�t�H���g�p�[�~�b�V�����Ƃ��Đݒ肷�邱�Ƃ͂Ȃ��̂ŁAumask�͐擪���ȗ�����3���Őݒ肷�邱�Ƃ��ł��܂��B
�ȉ��̗�ł́Aumask��022��3���Őݒ肵�Ă��܂����Aumask�R�}���h�̌��ʂ�0022�ɂȂ��Ă��܂��B

```
[sato@server ~]$ umask 022
[sato@server ~]$ umask
0022
```

### umask��ύX����
umask��ύX�������ꍇ�ɂ́Aumask�R�}���h�Őݒ肵��umask�l�������Ƃ��ė^���܂��B
�ȉ��̗�ł́Aumask�̒l��0002�ɕύX�����̂ŁA�V�K�ɍ쐬�����t�@�C���̃A�N�Z�X����664(-rw-rw-r--)�ɐݒ肳��Ă��܂��B

```
[sato@server ~]$ umask 0002
[sato@server ~]$ touch umasktest
[sato@server ~]$ ls -l umasktest 
-rw-rw-r--. 1 sato sato 0  7�� 26 18:21 umasktest
```

### �f�t�H���g��umask
�f�t�H���g��umask�̒l��0022�ł����A�����/etc/login.defs��UMASK�Ƃ��Ē�`����Ă��܂��B

```
$ cat /etc/login.defs
�i���j
# Default initial "umask" value used by login(1) on non-PAM enabled systems.
# Default "umask" value for pam_umask(8) on PAM enabled systems.
# UMASK is also used by useradd(8) and newusers(8) to set the mode for new
# home directories if HOME_MODE is not set.
# 022 is the default value, but 027, or even 077, could be considered
# for increased privacy. There is no One True Answer here: each sysadmin
# must make up their mind.
UMASK		022
�i���j

```

�܂��A���O�C���V�F���ȊO�ł�umask�̐ݒ�́Abash�V�F�����N������ۂɓǂݍ��܂��V�F���X�N���v�g/etc/bashrc�̒���umask���ݒ肳��Ă��܂��B

```
$ cat /etc/bashrc
�i���j
    # Set default umask for non-login shell only if it is set to 0
    [ `umask` -eq 0 ] && umask 022
�i���j
```

### setUID�̊m�F
setUID�����s�t�@�C���ɐݒ肳��Ă���ƁA���̎��s�t�@�C���͏��L���[�U�[�̌����Ŏ��s����܂��BsetUID���ݒ肳��Ă���ꍇ�Als�R�}���h�̏o�͂ŏ��L���[�U�[�̎��s�p�[�~�b�V�������us�v�ƕ\������܂��B

setUID���ݒ肳��Ă����Ƃ��āApasswd�R�}���h������܂��B��ʃ��[�U�[���p�X���[�h��ύX����ɂ́Aroot���[�U�[�������������߂�/etc/shadow�t�@�C���ɑ΂���ύX���K�v�ł��B�p�X���[�h��ύX����passwd�R�}���h�́A���L���[�U�[��root���[�U�[��setUID���ݒ肳��Ă���̂ŁA��ʃ��[�U�[��passwd�R�}���h�����s����ƁAroot���[�U�[�̌����Ŏ��s�����/etc/shadow�t�@�C���ɕύX�������邱�Ƃ��ł��܂��B

�R�}���h�����s�������[�U�[���u���s���[�U�[�v�AsetUID�Ō������ύX���ꂽ���[�U�[���u�������[�U�[�v�ƌĂт܂��B

�ȉ��̗�ł́Apasswd�R�}���h���ꎞ��~���āAps�R�}���h�Ŏ������[�U�[���m�F���Ă��܂��B

setUID���ݒ肳��Ă��邱�Ƃ��m�F���܂��B

```
$ ls -l /usr/bin/passwd
-rwsr-xr-x. 1 root root 32656  4�� 14  2022 /usr/bin/passwd
```

passwd�����s���ACtrl+Z�L�[�ňꎞ��~���܂��B�ꎞ��~��A�V�F���v�����v�g�ɖ߂����߂ɂ�Enter�L�[�������K�v������܂��B

```
$ passwd
���[�U�[ sato �̃p�X���[�h��ύX�B
Current password: ��Enter�L�[�����

[1]+  ��~                  passwd
$
```

ps�R�}���h�Ŏ������[�U�[���m�F���܂��Bpasswd�R�}���h�̎������[�U�[��root�ł��邱�Ƃ��m�F�ł��܂��B

```
$ ps aux | grep passwd
root        2377  0.0  0.4 233672  7296 pts/1    T    18:22   0:00 passwd
sato        2380  0.0  0.1 221676  2304 pts/1    S+   18:23   0:00 grep --color=auto passwd
```

fg�R�}���h�ňꎞ��~����passwd�R�}���h���t�H�A�O���E���h�v���Z�X�ɖ߂��܂��B

```
$ fg
passwd
passwd: �F�؃g�[�N������G���[
$ 
```

### setGID�̊m�F
setGID���ݒ肳��Ă���ƁA���L�O���[�v�̌����Ŏ��s����܂��BsetGID�͏��L�O���[�v�̎��s�p�[�~�b�V�������us�v�ƕ\������܂��B

setGID���ݒ肳��Ă����Ƃ��āAwrite�R�}���h������܂��B

```
$ ls -l /usr/bin/write
-rwxr-sr-x. 1 root tty 23984  3�� 13 15:30 /usr/bin/write
```

write�R�}���h�́A���O�C�����Ă��鑼�̃��[�U�[�ɑ΂��ă��b�Z�[�W�𑗂�R�}���h�ł��B�ȉ��̗�ł́Awrite�R�}���h���ꎞ��~���āAps�R�}���h�Ŏ����O���[�v���m�F���Ă��܂��B

2�̃��[�U�[�A�J�E���g�Ń��O�C�����܂��B�������[�U�[�A�J�E���g�ł��\���܂���Bsu�R�}���h�ŕύX���Ă��郆�[�U�[�ɂ�write�R�}���h�Ń��b�Z�[�W�𑗂邱�Ƃ͂ł��Ȃ��̂ŁA���O�C�����[�U�[���m�F����write�R�}���h�����s���ACtrl+Z�L�[�ňꎞ��~���܂��B

```
[sato@vbox ~]$ write linuc
^Z
[1]+  ��~                  write linuc
[sato@vbox ~]$
```

ps�R�}���h�Ŏ����O���[�v���m�F���܂��B

```
$ ps a -eo "%p %u %g %G %y %c" | grep write
     37 root     root     root     ?        kworker/R-write
   2388 sato     sato     tty      pts/1    write
```

�\���͍�����A�v���Z�XID�i%p�j�A���s���[�U�[�i%u�j�A���s�O���[�v�i%g�j�A�����O���[�v�i%G�j�A���s�[���i%y�j�A�R�}���h�i%c�j�ƂȂ��Ă��܂��B���s�����̂̓��[�U�[sato�ł����AsetGID����Ă��邽��tty�O���[�v�Ƃ��ē��삵�Ă��邱�Ƃ��m�F�ł��܂��B

tty�Ƃ́uTele-TYpewriter�v�̈Ӗ��ŁA�[����\���܂��Bwrite�R�}���h�̓��O�C�����Ă��鑼�̃��[�U�[�̒[���Ƀ��b�Z�[�W��\�����邽�߂�setGID���s���Ď����O���[�v��tty�O���[�v�ɂ��Ă���킯�ł��B

�ꎞ��~���Ă���write�R�}���h���t�H�A�O���E���h�ɖ߂��A�I�����Ă����܂��B

```
[sato@vbox ~]$ fg
write linuc
^C[sato@vbox ~]$
```

### �X�e�B�b�L�[�r�b�g
�X�e�B�b�L�[�r�b�g���ݒ肳�ꂽ�t�@�C����f�B���N�g���́A�u���ׂẴ��[�U�[���������߂邪�A���L�҂����폜�ł��Ȃ��v�Ƃ����A�N�Z�X�������ݒ肳��܂��B

���Ƃ���/tmp�f�B���N�g���ɑ΂��ăX�e�B�b�L�[�r�b�g���ݒ肳��Ă��܂��B/tmp�f�B���N�g���͑S�Ẵ��[�U�[��A�v���P�[�V�������������߂�f�B���N�g���Ƃ��āA�ꎞ�t�@�C���̍쐬�ȂǂɎg�p����Ă��܂��B������/tmp�f�B���N�g���̃p�[�~�b�V������777�irwxrwxrwx�j�ɐݒ肷��ƁA�쐬�����t�@�C���𑼂̃��[�U�[���폜�ł��Ă��܂��܂��B������/tmp�f�B���N�g���ɃX�e�B�b�L�[�r�b�g��ݒ肷��ƁA���̃t�@�C�����폜�ł���͍̂쐬�������[�U�[�݂̂ƂȂ�܂��B

�X�e�B�b�L�[�r�b�g���ݒ肳��Ă���ƁAls�R�}���h�̏o�͂ł��̑��̃��[�U�[�̎��s�p�[�~�b�V�������ut�v�ƕ\������܂��B

```
$ ls -ld /tmp
drwxrwxrwt. 17 root root 4096  7�� 26 18:17 /tmp
```

���[�U�[sato��/tmp/sbittest���쐬���A�p�[�~�b�V������666�ɐݒ肵�܂��B

```
[sato@vbox ~]$ touch /tmp/sbittest
[sato@vbox ~]$ chmod 666 /tmp/sbittest
[sato@vbox ~]$ ls -l /tmp/sbittest
-rw-rw-rw-. 1 sato sato 0  7�� 26 18:29 /tmp/sbittest
```

���[�U�[suzuki��/tmp/sbittest�ɏ������݂����܂��B���̑��̃��[�U�[�ɑ΂��鏑�����݂̃p�[�~�b�V�������t�^����Ă���̂ŏ������݂��s���܂��B

```
[suzuki@vbox ~]$ echo "suzuki" >> /tmp/sbittest
[suzuki@vbox ~]$ cat /tmp/sbittest
suzuki
```

���[�U�[suzuki��/tmp/sbittest���폜���悤�Ƃ��܂����A�X�e�B�b�L�[�r�b�g�������č폜�ł��܂���B

```
[suzuki@vbox ~]$ rm /tmp/sbittest
rm: '/tmp/sbittest' ���폜�ł��܂���: ������Ă��Ȃ�����ł�
```

���[�U�[sato��/tmp/sbittest���폜���܂��B���L���[�U�[�͍폜���s���܂��B

```
[sato@vbox ~]$ rm /tmp/sbittest
[sato@vbox ~]$ ls -l /tmp/sbittest
ls: '/tmp/sbittest' �ɃA�N�Z�X�ł��܂���: ���̂悤�ȃt�@�C����f�B���N�g���͂���܂���
```

## SELinux
SELinux��Linux�J�[�l��2.6����������ꂽ�Aroot���[�U�[�̓����ɑ΂��Ă��������|���邱�Ƃ��ł��鋭���A�N�Z�X����iMAC�AMandatory Access Control�j�̎d�g�݂ł��B

�{���ȏ��ł́ASELinux�̊�{�I�ȊǗ��ɂ��ĉ�����܂��BSELinux�̂��ڂ��������ɂ��ẮA�wLinux�Z�L�����e�B�W�����ȏ��x���Q�Ƃ��Ă��������B

### SELinux�̎d�g��
SELinux�ł́A�v���Z�X��t�@�C���Ȃ�Linux�̑S�Ẵ��\�[�X�ɑ΂��āu�R���e�L�X�g�v�icontexts�j�ƌĂ΂�郉�x����t�����A�u�T�u�W�F�N�g�v�isubject�B�A�N�Z�X���鑤�B��Ƀv���Z�X�j���u�I�u�W�F�N�g�v�iobject�B�A�N�Z�X����鑤�B��Ƀt�@�C����f�B���N�g���A�v���Z�X�j�ɑ΂��ăA�N�Z�X���s���ۂɁA���̃R���e�L�X�g���r���邱�Ƃɂ��A�N�Z�X������s���܂��B

�����̃R���e�L�X�g��g�ݍ��킹�āA�A�N�Z�X�̉ۂ��s�����[����SELinux�ł́u�|���V�[�v�ƌĂт܂��B�|���V�[�̏ڍׂȐ����ƏC���Ɋւ��ẮA�wLinux�Z�L�����e�B�W�����ȏ��x���Q�Ƃ��Ă��������B

### SELinux�̗L���A�����̊m�F
SELinux�̏�Ԃ�getenforce�R�}���h�Ŋm�F�ł��܂��B

```
$ getenforce
Enforcing
```

getenforce�R�}���h�̌��ʂ͈ȉ��̒ʂ�ł��B

|����|���|
|-------|-------|
|Enforcing|SELinux�ɂ��A�N�Z�X���䂪�L��|
|Permissive|SELinux�͗L���ł��邪���싑�ۂ͍s��Ȃ�|
|Disabled|SELinux�ɂ��A�N�Z�X���䂪����|

SELinux�̏�Ԃ́Asetenforce�R�}���h�ɂ�铮�I�ȕύX���A�ݒ�t�@�C��/etc/selinux/config�ɂ��i���I�ȕύX�̂����ꂩ�ŕύX�ł��܂��B

### SELinux�̋���
�ŋ߂̃f�B�X�g���r���[�V�����ł́ASELinux�𖳌��iDisabled�j�ɂ���̂͐������ꂸ�A�܂����I�ύX�A�ݒ�t�@�C���ɂ��ύX���s���Ȃ��Ȃ��Ă���̂ŁA�������̕��@�ɂ��Ă͉�����܂���BSELinux�𖳌�������̂ł͂Ȃ��A�������ݒ肷����@�A�܂�����ɓ��삵�Ȃ��ꍇ�ɂ�Permissive�Ɉꎞ�I�ɐݒ肵�ă��O���m�F���A�K�؂ɐݒ肷����@���w��ł��������B

### setenforce�R�}���h�ɂ��SELinux�̓��I�ȕύX
setenforce�R�}���h��SELinux�̏�Ԃ𓮓I�ɕύX�ł��܂��B�ύX��root���[�U�[�Ŏ��s����K�v������܂��B

�������A���I�ɕύX�ł���̂�Enforcing��Permissive�̐؂�ւ��݂̂ŁASELinux��L�����疳���iDisabled�j�ɁA���邢�͖�������L���ɕύX���邱�Ƃ͂ł��܂���B

```
setenforce [ Enforcing | Permissive | 1 | 0 ]
```

���Ƃ��΁A�V�X�e����SELinux�ɂ��A�N�Z�X������ꎞ�I�ɓK�p���Ȃ��悤�ɂ������Ƃ��ɂ͏�Ԃ�Permissive�ɕύX���܂��BSELinux�ɂ��A�N�Z�X����ł̓���̋��ۂ͍s���Ȃ��Ȃ�܂����A�f�o�b�O�Ȃǂ̗p�r�̂��߂�SELinux�̃|���V�[�ᔽ����������ƃ��O�͏o�͂���܂��B
�V�X�e�����v�����悤�ɓ��삹���ASELinux�������Ǝv���鎞�Ȃǂ�Permissive�ɐݒ肵�āASELinux���������ǂ����̐؂蕪����Ƃ��s���܂��B

```
$ sudo setenforce permissive
$ getenforce 
Permissive
```

### SELinux�̉i���I�ȕύX
SELinux�𖳌��ɂ���A���邢�͖�������L���ɕύX����ɂ�SELinux�̐ݒ�t�@�C��/etc/selinux/config�̐ݒ��ύX���܂��B�V�X�e�����ċN������ƁA�ݒ肪���f����܂��B

/etc/selinux/config��ҏW���A�ݒ荀��SELINUX�̒l��permissive�ɕύX���܂��B

```
$ sudo vi /etc/selinux/config
```

�ݒ��ύX���܂��B

```
#SELINUX=enforcing
SELINUX=permissive
```

�V�X�e�����ċN�����A�ēx���O�C������getenforce�R�}���h��SELinux��Permissive�ɂȂ������Ƃ��m�F���܂��B

```
$ getenforce
Permissive
```

/etc/selinux/config��ҏW���A�ݒ荀��SELINUX�̒l��enforcing�ɕύX���܂��B

```
$ sudo vi /etc/selinux/config
```

```
SELINUX=enforcing
#SELINUX=permissive
```

�V�X�e�����ċN�����A�ēx���O�C������getenforce�R�}���h��SELinux���L���iEnforcing�j�ɂȂ������Ƃ��m�F���܂��B

```
$ getenforce
Enforcing
```

### �R���e�L�X�g�̊m�F
�R���e�L�X�g�̓t�@�C���Ȃǂɐݒ肳��ASELinux�̃A�N�Z�X����ɗ��p����܂��B�R���e�L�X�g�́A����4�̎��ʎq�ō\������Ă��܂��B

* ���[�U�[(user)
* ���[��(role)
* �^�C�v(type)�F�v���Z�X�̏ꍇ�ɂ͓��Ɂu�h���C���v�Ƃ������܂�
* MLS�F���x��Multi Level Security��񋟂ł��܂����A�ʏ�̃V�X�e���ł͂��܂�g���܂���

�R���e�L�X�g�́A�����̎��ʎq��g�ݍ��킹�āA�ȉ��̌`���ŕ\����܂��B

```
���[�U�[:���[��:�^�C�v:MLS���x��
```

SELinux�ł̃A�N�Z�X����́A�^�C�v�^�h���C���ɑ΂��ċ����铮����`�����u�|���V�[�v�Ɋ�Â��čs���܂��B�^�C�v�^�h���C���̖��O�́A������v���Z�X����������Ă��܂��B���Ƃ��΁AApache Web�T�[�o�[�̃v���Z�X�ł���httpd�ɂ́uhttpd_t�v�Ƃ����h���C���������Ă��܂��B

### Apache Web�T�[�o�[�̃C���X�g�[��
���̌��SELinux�̓���m�F�ł�Apache Web�T�[�o�[���g���܂��B�܂��C���X�g�[������Ă��Ȃ��ꍇ�ɂ́Adnf�R�}���h���g���ăC���X�g�[�����܂��Bdnf�R�}���h�ɂ��Ă͑�5�͂ŏڂ���������܂��B

```
$ sudo dnf install httpd -y
```

### �R���e�L�X�g�̊m�F
SELinux�̃A�N�Z�X����ŗp������R���e�L�X�g�́A�v���Z�X��t�@�C�����Q�Ƃ���R�}���h��-Z�I�v�V���������Ď��s���邱�ƂŊm�F�ł��܂��B

���Ƃ��΁A�t�@�C����f�B���N�g���ɕt�^����Ă���R���e�L�X�g���m�F����ɂ�ls -lZ�R�}���h�����s���܂��B��Ƃ��āAApache Web�T�[�o�[�ihttpd�j�Ɋւ���t�@�C�����m�F���Ă݂܂��B

```
$ ls -lZ /var/www
���v 0
drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_script_exec_t:s0  6  3�� 13 03:17 cgi-bin
drwxr-xr-x. 2 root root system_u:object_r:httpd_sys_content_t:s0     24  3�� 13 03:17 html
```

Web�T�[�o�[�̃R���e���c���܂�/var/www/html�f�B���N�g���ɂ́uhttpd_sys_content_t�v�Ƃ����^�C�v���t�^����Ă��܂��B����/var/www/html�f�B���N�g�����Ƀt�@�C�����쐬����ƁA�e�f�B���N�g���̃R���e�L�X�g�ɏ]���ăt�@�C���ɃR���e�L�X�g���t�^����܂��B

�m�F�̂��߂ɁA/var/www/html�f�B���N�g���ȉ���index.html�t�@�C�����쐬���Ă݂܂��B
�e�f�B���N�g������R���e�L�X�g���p�����Aindex.html�t�@�C���Ɂuhttpd_sys_content_t�v�Ƃ����^�C�v���t�^����Ă��܂��B

```
$ sudo touch /var/www/html/index.html 
$ ls -lZ /var/www/html/index.html 
-rw-r--r--. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0 0  7�� 26 18:40 /var/www/html/index.html
```

�܂��A�v���Z�X�̃R���e�L�X�g�̏����m�F����ɂ́Aps axZ�R�}���h�����s���܂��B

�ȉ��̗�ł́Ahttpd�̃v���Z�X���m�F����ƁAhttpd_t�h���C�����t�^����Ă��邱�Ƃ�������܂��B

```
$ sudo systemctl start httpd
$ ps axZ | grep httpd
system_u:system_r:httpd_t:s0       2412 ?        Ss     0:00 /usr/sbin/httpd -DFOREGROUND
system_u:system_r:httpd_t:s0       2413 ?        S      0:00 /usr/sbin/httpd -DFOREGROUND
�i���j
```

SELinux�̃|���V�[�ł́Ahttpd�v���Z�X�ɕt�^����Ă���httpd_t�h���C�����A�uhttpd_sys_content_t�v�Ȃǂ̃^�C�v���t�^����Ă���t�@�C����read�i�ǂݎ��j�Ȃǂ��s����悤�Ɍ������ݒ肳��Ă��܂��B

### Boolean���g����SELinux�̐���
SELinux��L���ɂ��ăA�v���P�[�V���������܂����삵�Ȃ��ꍇ�ɂ́ASELinux�̃A�N�Z�X����ɂ���ăv���Z�X���t�@�C����f�B���N�g���ɃA�N�Z�X�ł��Ȃ����Ƃ������̏ꍇ������܂��B���̂悤�Ȏ��ɂ́ASELinux�̃|���V�[��ݒ肷��K�v������܂��B

��ʓI�ȃ|���V�[�̐ݒ�́uBoolean�v�i�u�[���A���j�ƌĂ΂��ݒ�̗L���A�����őΉ��ł��܂��BBoolean�́A�p�b�P�[�W���C���X�g�[������ƁA���̃\�t�g�E�F�A�p�ɗp�ӂ��ꂽBoolean���ǉ������ꍇ������܂��B

�����A�Ǝ��̃A�v���P�[�V�������g�p������A�A�v���P�[�V�����̐ݒ��啝�ɕύX�����ꍇ�ɂ́A�|���V�[��ǉ��A�C������K�v������܂��B�|���V�[�̒ǉ��A�C�����@�ɂ��ẮwLinux�Z�L�����e�B�W�����ȏ��x���Q�Ƃ��Ă��������B

�ȉ��̗�ł́AApache Web�T�[�o�[(httpd)�Ɋւ���|���V�[��ݒ肵�Ă��܂��B

getsebool�R�}���h��Boolean�̐ݒ�󋵈ꗗ���m�F���܂��BBoolean���ɂ͊֌W����v���Z�X�����܂܂�Ă���̂ŁAgrep�R�}���h�Łuhttpd�v���L�[���[�h�ɂ��Č������܂��B

```
$ getsebool -a | grep httpd
httpd_anon_write --> off
httpd_builtin_scripting --> on
�i���j
httpd_enable_homedirs --> off
�i���j
```

��̍�Ƃ�httpd_enable_homedirs��Boolean��ݒ肵�܂��B����Boolean�́AApache Web�T�[�o�[�̃��[�U�[�z�[���f�B���N�g���@�\�Ɋւ���ݒ�ł��B���[�U�[�z�[���f�B���N�g���@�\�́A�e���[�U�[�̃z�[���f�B���N�g���ɍ쐬���ꂽpublic_html�f�B���N�g������Web�R���e���c�Ƃ��Č��J����d�g�݂ł��B

Apache Web�T�[�o�[�̐ݒ�t�@�C��/etc/httpd/conf.d/userdir.conf���C�����AUserDir�f�B���N�e�B�u��ݒ肵�ă��[�U�[�z�[���f�B���N�g���@�\��L���ɂ��܂��B

```
$ sudo vi /etc/httpd/conf.d/userdir.conf

�i���j
<IfModule mod_userdir.c>
    #
    # UserDir is disabled by default since it can confirm the presence
    # of a username on the system (depending on home directory
    # permissions).
    #
    #UserDir disabled ���s����#��ǉ����ăR�����g�A�E�g

    #
    # To enable requests to /~user/ to serve the user's public_html
    # directory, remove the "UserDir disabled" line above, and uncomment
    # the following line instead:
    #
    UserDir public_html ���s����#���폜
�i���j
```

httpd�T�[�r�X���ċN�����܂��B

```
$ sudo systemctl restart httpd
```

���[�U�[linuc�̃z�[���f�B���N�g����public_html�f�B���N�g�����쐬���܂��B

```
$ pwd
/home/linuc
$ mkdir public_html
```

/home/linuc�f�B���N�g���A/home/linuc/public_html�f�B���N�g���̃p�[�~�b�V������711�ɐݒ肵�܂��B

```
$ chmod 711 /home/linuc
$ chmod 711 /home/linuc/public_html/
```

public_html�f�B���N�g����index.html�t�@�C�����쐬���܂��B

```
$ echo "SELinux test" > /home/linuc/public_html/index.html
```

�u���E�U���N�����A�uhttp://localhost/~linuc/�v�ɃA�N�Z�X���܂��BSELinux�̃A�N�Z�X���䂪�L���ɂȂ��Ă��邽�߁A�uForbidden�v���\������܂��B

![Forbidden](Forbidden.png)

���O�t�@�C��/var/log/audit/audit.log���m�F���܂��Bhttpd(httpd_t)�����[�U�[�z�[���f�B���N�g��(user_home_dir_t)�ɃA�N�Z�X�ł��Ȃ������Ƃ������O���o�͂���Ă��܂��B

```
$ sudo cat /var/log/audit/audit.log | grep index.html
type=AVC msg=audit(1753523214.725:248): avc:  denied  { getattr } for  pid=2624 comm="httpd" path="/home/linuc/public_html/index.html" dev="dm-0" ino=51579776 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_user_content_t:s0 tclass=file permissive=0
type=AVC msg=audit(1753523214.725:249): avc:  denied  { getattr } for  pid=2624 comm="httpd" path="/home/linuc/public_html/index.html" dev="dm-0" ino=51579776 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_user_content_t:s0 tclass=file permissive=0
```

setsebool�R�}���h�����s���āABoolean�uhttpd_enable_homedirs�v��L���ɐݒ肵�܂��B

```
$ getsebool httpd_enable_homedirs
httpd_enable_homedirs --> off
$ sudo setsebool httpd_enable_homedirs on
$ getsebool httpd_enable_homedirs
httpd_enable_homedirs --> on
```

�ēx�u���E�U�Łuhttp://localhost/~linuc/�v�ɃA�N�Z�X���܂��BBoolean�ŃA�N�Z�X�������ꂽ�̂ŁA�쐬�����y�[�W���\������܂��B

## LVM�̐ݒ�
LVM�iLogical Volume Manager�j�́A�n�[�h�f�B�X�N�Ȃǂ̋L���}�̂̕����I�ȏ�Ԃ��B�����A�_���I�ȃC���[�W�ŊǗ����邽�߂̋Z�p�ł��B

LVM���g�����ƂŁA�����̃n�[�h�f�B�X�N�ɂ܂��������{�����[�����쐬�ł���悤�ɂȂ�A�t�@�C���V�X�e���̗e�ʂ�����Ȃ��Ȃ����ꍇ�̗e�ʂ̒ǉ����ȒP�ɂȂ�܂��B�{�����[���̑���́A�V�X�e�����ċN�����邱�ƂȂ��s�����Ƃ��ł��܂��B

�܂��A�n�[�h�f�B�X�N�ɏ�Q�������������ɂ́A�V����HDD��ǉ����āA���Ă���HDD���O���Ȃǂ̏�Q�Ή����e�ՂɂȂ�܂��B
���ɂ��A�X�i�b�v�V���b�g����邱�Ƃ��ł���Ȃǂ̃����b�g������܂��B

���݂̈�ʓI��Linux�f�B�X�g���r���[�V�����ł́A�C���X�g�[������LVM�Ńp�[�e�B�V�������쐬�ł��܂��BAlmaLinux�ł́A�C���X�g�[�����Ɏ����p�[�e�B�V�����ݒ��I������ƁA�f�t�H���g��LVM���g�p���ăX�g���[�W��ݒ肵�܂��B

LVM�̏ڂ��������Ɋւ��ẮA�w���M���V�X�e���\�z�W�����ȏ��x���Q�Ƃ��Ă��������B

### ���K�p�f�B�X�N�̒ǉ�
�ȉ��̎��K�ł́A�f�B�X�N��ǉ����ALVM�ŊǗ����܂��B���̂��߂̉��z�n�[�h�f�B�X�N�����z�}�V���ɒǉ����܂��B

1. �Q�X�gOS���V���b�g�_�E�����A���z�}�V�����~����
1. VirtualBox�̉��z�}�V���́u�ݒ�v�Łu�X�g���[�W�v���J��
1. �u�R���g���[���[:SATA�v�ŉ��z�n�[�h�f�B�X�N�ǉ��̃{�^�����N���b�N����
1. �u�n�[�h�f�B�X�N�I���v�_�C�A���O�Łu�쐬�v���N���b�N����
1. �u���z�n�[�h�f�B�X�N�̍쐬�v�_�C�A���O�Łu�����v���N���b�N����
1. �쐬���ꂽ���z�n�[�h�f�B�X�N��I�����A�u�I���v���N���b�N����
1. �u�R���g���[���[:SATA�v�ɉ��z�n�[�h�f�B�X�N���ǉ����ꂽ���Ƃ��m�F���āA�uOK�v���N���b�N����
1. ���z�}�V�����N������

### �f�o�C�X���̊m�F
���z�n�[�h�f�B�X�N�̃f�o�C�X�����m�F���܂��B�X�g���[�W�f�o�C�X�̊m�F�ɂ�lsblk�R�}���h�����s���܂��B

```
$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                       8:0    0   20G  0 disk
����sda1                    8:1    0  600M  0 part /boot/efi
����sda2                    8:2    0    1G  0 part /boot
����sda3                    8:3    0 18.4G  0 part
  ����almalinux_vbox-root 253:0    0 16.4G  0 lvm  /
  ����almalinux_vbox-swap 253:1    0    2G  0 lvm  [SWAP]
sdb                       8:16   0   20G  0 disk
sr0                      11:0    1 1024M  0 rom
```

sdb���V���ɒǉ��������z�n�[�h�f�B�X�N�̃f�o�C�X���ł��B

/dev�f�B���N�g���ɂ��f�o�C�X�t�@�C�����쐬����Ă��܂��B

```
$ ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sda3  /dev/sdb
```

/dev/sdb���V���ɒǉ��������z�n�[�h�f�B�X�N�̃f�o�C�X�t�@�C���ł��B

### �����{�����[���iPV�j
LVM�́A�����{�����[���iPV: Physical Volume�j�A�{�����[���O���[�v�iVG: Volume Group�j�A�_���{�����[���iLV: Logical Volume�j��3�ō\������Ă��܂��B

�����{�����[��(PV)�́A�����f�B�X�N�̃p�[�e�B�V�����P�ʂň����܂��B��̕����f�B�X�N���ׂĂ����PV�Ƃ��Ĉ������Ƃ��ł��܂����A��̕����f�B�X�N���Ƀp�[�e�B�V�����𕡐��쐬���A���ꂼ��̃p�[�e�B�V������ʁX��PV�Ƃ��Ĉ������Ƃ��ł��܂��B

PV���쐬����ɂ́A�p�[�e�B�V�������쐬���A�p�[�e�B�V�����^�C�v��8E�ɐݒ肵�܂��B

�ȉ��̗�ł́ALinux�}�V���ɐV�K�ɒǉ�����/dev/sdb�Ƃ��ĔF������Ă���n�[�h�f�B�X�N��LVM�Ŏg�p�ł���悤�Afdisk�Ńp�[�e�B�V�������쐬����PV�Ƃ��Đݒ肵�Ă��܂��B�����ɁA��̍�Ƃŗ̈�g�����s�����߂̒ǉ��p�[�e�B�V�������쐬���Ă����܂��B

```
$ sudo fdisk /dev/sdb

fdisk (util-linux 2.37.4) �ւ悤�����B
�����Őݒ肵�����e�́A�������݃R�}���h�����s����܂Ń������݂̂ɕێ�����܂��B
�������݃R�}���h���g�p����ۂ́A���ӂ��Ď��s���Ă��������B

�f�o�C�X�ɂ͔F���\�ȃp�[�e�B�V������񂪊܂܂�Ă��܂���B
�V���� DOS �f�B�X�N���x�����쐬���܂����B���ʎq�� 0x3370db49 �ł��B

�R�}���h (m �Ńw���v): n ���V�K�p�[�e�B�V�����쐬��n�����
�p�[�e�B�V�����^�C�v
   p   ��{�p�[�e�B�V���� (0 �v���C�}��, 0 �g��, 4 ��)
   e   �g���̈� (�_���p�[�e�B�V����������܂�)
�I�� (����l p): p ����{�p�[�e�B�V������p�����
�p�[�e�B�V�����ԍ� (1-4, ����l 1): 1 ���p�[�e�B�V�����ԍ�1�����
�ŏ��̃Z�N�^ (2048-41943039, ����l 2048): ���f�t�H���g���g���̂�Enter�����
�ŏI�Z�N�^, +/-�Z�N�^�ԍ� �܂��� +/-�T�C�Y{K,M,G,T,P} (2048-41943039, ����l 41943039): +10GB ��+10GB�����

�V�����p�[�e�B�V���� 1 ���^�C�v Linux�A�T�C�Y 9.3 GiB �ō쐬���܂����B

�R�}���h (m �Ńw���v): n ���V�K�p�[�e�B�V�����쐬��n�����
�p�[�e�B�V�����^�C�v
   p   ��{�p�[�e�B�V���� (1 �v���C�}��, 0 �g��, 3 ��)
   e   �g���̈� (�_���p�[�e�B�V����������܂�)
�I�� (����l p): p ����{�p�[�e�B�V������p�����
�p�[�e�B�V�����ԍ� (2-4, ����l 2): 2 ���p�[�e�B�V�����ԍ�2�����
�ŏ��̃Z�N�^ (19533824-41943039, ����l 19533824): ���f�t�H���g���g���̂�Enter�����
�ŏI�Z�N�^, +/-�Z�N�^�ԍ� �܂��� +/-�T�C�Y{K,M,G,T,P} (19533824-41943039, ����l 41943039): ���f�t�H���g���g���̂�Enter�����

�V�����p�[�e�B�V���� 2 ���^�C�v Linux�A�T�C�Y 10.7 GiB �ō쐬���܂����B

�R�}���h (m �Ńw���v): p ���ݒ���m�F����̂�p�����
�f�B�X�N /dev/sdb: 20 GiB, 21474836480 �o�C�g, 41943040 �Z�N�^
�f�B�X�N�^��: VBOX HARDDISK
�P��: �Z�N�^ (1 * 512 = 512 �o�C�g)
�Z�N�^�T�C�Y (�_�� / ����): 512 �o�C�g / 512 �o�C�g
I/O �T�C�Y (�ŏ� / ����): 512 �o�C�g / 512 �o�C�g
�f�B�X�N���x���̃^�C�v: dos
�f�B�X�N���ʎq: 0x3370db49

�f�o�C�X   �N�� �J�n�ʒu �I���ʒu   �Z�N�^ �T�C�Y Id �^�C�v
/dev/sdb1           2048 19533823 19531776   9.3G 83 Linux
/dev/sdb2       19533824 41943039 22409216  10.7G 83 Linux

�R�}���h (m �Ńw���v): t ���p�[�e�B�V�����̃^�C�v��ύX����t�����
�p�[�e�B�V�����ԍ� (1,2, ����l 2): 1 ���p�[�e�B�V�����ԍ�1�����
16 �i���R�[�h �܂��͕ʖ� (L �ŗ��p�\�ȃR�[�h���ꗗ�\�����܂�): 8e ��Linux LVM�̃R�[�h8e�����

�p�[�e�B�V�����̃^�C�v�� 'Linux' ���� 'Linux LVM' �ɕύX���܂����B

�R�}���h (m �Ńw���v): t ���p�[�e�B�V�����̃^�C�v��ύX����t�����
�p�[�e�B�V�����ԍ� (1,2, ����l 2): 2 ���p�[�e�B�V�����ԍ�2�����
16 �i���R�[�h �܂��͕ʖ� (L �ŗ��p�\�ȃR�[�h���ꗗ�\�����܂�): 8e ��Linux LVM�̃R�[�h8e�����

�p�[�e�B�V�����̃^�C�v�� 'Linux' ���� 'Linux LVM' �ɕύX���܂����B

�R�}���h (m �Ńw���v): p ���ݒ���m�F����̂�p�����
�f�B�X�N /dev/sdb: 20 GiB, 21474836480 �o�C�g, 41943040 �Z�N�^
�f�B�X�N�^��: VBOX HARDDISK
�P��: �Z�N�^ (1 * 512 = 512 �o�C�g)
�Z�N�^�T�C�Y (�_�� / ����): 512 �o�C�g / 512 �o�C�g
I/O �T�C�Y (�ŏ� / ����): 512 �o�C�g / 512 �o�C�g
�f�B�X�N���x���̃^�C�v: dos
�f�B�X�N���ʎq: 0x3370db49

�f�o�C�X   �N�� �J�n�ʒu �I���ʒu   �Z�N�^ �T�C�Y Id �^�C�v
/dev/sdb1           2048 19533823 19531776   9.3G 8e Linux LVM
/dev/sdb2       19533824 41943039 22409216  10.7G 8e Linux LVM

�R�}���h (m �Ńw���v): w ���p�[�e�B�V����������������w�����
�p�[�e�B�V������񂪕ύX����܂����B
ioctl() ���Ăяo���ăp�[�e�B�V���������ēǂݍ��݂��܂��B
�f�B�X�N�𓯊����Ă��܂��B
```

�f�o�C�X�t�@�C�����m�F���܂��B

```
$ lsblk /dev/sdb
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sdb      8:16   0   20G  0 disk
����sdb1   8:17   0  9.3G  0 part
����sdb2   8:18   0 10.7G  0 part
$ ls /dev/sdb*
/dev/sdb  /dev/sdb1  /dev/sdb2
```

�f�o�C�X�t�@�C����/dev/sdb1��/dev/sdb2���ǉ����ꂽ�̂��m�F�ł��܂��B

### �{�����[���O���[�v�iVG�j
�{�����[���O���[�v(VG)�́A1�ȏ�̕����{�����[���iPV�j���ЂƂ܂Ƃ߂ɂ������̂ł��B����͉��z�I�ȃf�B�X�N�ɑ������܂��B

�{�����[���O���[�v��vgcreate�R�}���h�ō쐬���܂��B

```
vgcreate �{�����[���� PV�f�o�C�X�� [PV�f�o�C�X�� ...]
```

���Ƃ��΁A�����{�����[���iPV�j�Ƃ��č쐬����/dev/sdb1���g����Volume00�Ƃ������O�̃{�����[���O���[�v���쐬����ɂ́A�ȉ���vgcreate�R�}���h�����s���܂��B

```
$ sudo vgcreate Volume00 /dev/sdb1
  Physical volume "/dev/sdb1" successfully created
  Volume group "Volume00" successfully created
```

�܂��A�{�����[���O���[�v�̏���vgscan�R�}���h�Ŋm�F�ł��܂��B

```
$ sudo vgscan
  Found volume group "almalinux_vbox" using metadata type lvm2
  Found volume group "Volume00" using metadata type lvm2
```

### �_���{�����[���iLV�j
�_���{�����[���iLV�j�́A�{�����[���O���[�v�iVG�j��ɍ쐬���鉼�z�I�ȃp�[�e�B�V�����ł��BLinux����̓f�o�C�X�Ƃ��ĔF������܂��B�n�[�h�f�B�X�N�ɕ����p�[�e�B�V�������쐬����ꍇ�Ɠ��l�ɁA�{�����[���O���[�v�����ׂĈ�̘_���{�����[���Ƃ��邱�Ƃ��ł��܂����A��̃{�����[���O���[�v�𕡐��̘_���{�����[���ɕ������Ďg�p���邱�Ƃ��ł��܂��B

�_���{�����[����lvcreate�R�}���h���g���č쐬���܂��B

```
lvcreate -L �T�C�Y -n �_���{�����[���� �{�����[���O���[�v��
```

���Ƃ��΁A�{�����[���O���[�vVolume00�ɃT�C�Y1GB�A�_���{�����[�����uLogVol01�v�̘_���{�����[�����쐬����ɂ́A�ȉ���lvcreate�R�}���h�����s���܂��B

```
$ sudo lvcreate -L 1024M -n LogVol01 Volume00
  Logical volume "LogVol01" created.
```

### �_���{�����[���Ƀt�@�C���V�X�e���̍쐬
�쐬�����_���{�����[���𗘗p����ɂ́A�ʏ�̃p�[�e�B�V�����Ɠ������_���{�����[����Ƀt�@�C���V�X�e�����쐬���܂��B�_���{�����[���́A�ȉ��̂悤�ȃf�o�C�X�Ƃ��Ĉ������Ƃ��ł��܂��B

```
/dev/�{�����[���O���[�v��/�_���{�����[����
```

/dev/Volume00/LogVol01���ext4�t�@�C���V�X�e�����쐬���邽�߂ɁAmkfs�R�}���h�����s���܂��B

```
$ sudo mkfs -t ext4 /dev/Volume00/LogVol01 
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: 5ca94cf6-2d63-4ce2-89da-c2dc251d9e42
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

mount�R�}���h���g���āA/dev/Volume00/LogVol01���}�E���g���܂��B

```
$ sudo mkdir /mnt/LVMtest
$ sudo mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest
$ mount | grep /mnt/LVMtest
/dev/mapper/Volume00-LogVol01 on /mnt/LVMtest type ext4 (rw,relatime,seclabel)
```

### �{�����[���O���[�v�ւ̃f�B�X�N�̒ǉ�
�����̃{�����[���O���[�vVolume00�ɕ����{�����[��/dev/sdb2��ǉ����܂��B

vgextend�R�}���h�����s���āA�����{�����[��/dev/sdb2���{�����[���O���[�vVolume00�ɒǉ����܂��B

```
$ sudo vgextend Volume00 /dev/sdb2
  Physical volume "/dev/sdb2" successfully created.
  Volume group "Volume00" successfully extended
```

vgdisplay�R�}���h�����s���āA�{�����[���O���[�vVolume00�̏����m�F���܂��BPV�iPhysical volume�j�̐���2�ƂȂ��Ă���A/dev/sdb2��������Ă��邱�Ƃ�������܂��B

```
$ sudo vgdisplay Volume00
  --- Volume group ---
  VG Name               Volume00
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <20.00 GiB
  PE Size               4.00 MiB
  Total PE              5119
  Alloc PE / Size       256 / 1.00 GiB
  Free  PE / Size       4863 / <19.00 GiB
  VG UUID               HsR4Jt-H94l-Ulsw-rvaz-Jebs-6my2-eGtfcD
```

### �_���{�����[���̊g��
LVM�ł́A�_���{�����[���̃T�C�Y��ύX�ł��܂��B�܂��ALVM�̘_���{�����[����ɍ쐬���ꂽext4�t�@�C���V�X�e���́A�t�@�C���V�X�e�����}�E���g�����܂܊g���ł��܂��B

df�R�}���h�����s���āA���݂̃t�@�C���V�X�e���̗e�ʂ��m�F���܂��B���݂̗e�ʂ�1GB�ł��B

```
$ df -h /mnt/LVMtest
�t�@�C���V�X                  �T�C�Y  �g�p  �c�� �g�p% �}�E���g�ʒu
/dev/mapper/Volume00-LogVol01   974M   24K  907M    1% /mnt/LVMtest
```

lvextend�R�}���h�����s���āA�_���{�����[��LogVol01�̃T�C�Y��2G�܂Ŋg�債�܂��B

```
$ sudo lvextend -L 2G /dev/Volume00/LogVol01
  Size of logical volume Volume00/LogVol01 changed from 1.00 GiB (256 extents) to 2.00 GiB (512 extents).
  Logical volume Volume00/LogVol01 successfully resized.
```

resize2fs�R�}���h�����s���āA�t�@�C���V�X�e�����g�債�܂��B

```
$ sudo resize2fs /dev/Volume00/LogVol01
resize2fs 1.46.5 (30-Dec-2021)
Filesystem at /dev/Volume00/LogVol01 is mounted on /mnt/LVMtest; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/Volume00/LogVol01 is now 524288 (4k) blocks long.
```

df�R�}���h�ōēx�e�ʂ��m�F���܂��B�e�ʂ�2GB�ɑ����Ă��邱�Ƃ��m�F�ł��܂��B

```
$ $ df -h /mnt/LVMtest
�t�@�C���V�X                  �T�C�Y  �g�p  �c�� �g�p% �}�E���g�ʒu
/dev/mapper/Volume00-LogVol01   2.0G   24K  1.9G    1% /mnt/LVMtest
```

### �_���{�����[���̏k��
�^�p��A���̘_���{�����[�����g�債�������̗��R�Ŏg�p���̒Ⴂ�_���{�����[���̏k�����s���ꍇ������܂��B
�_���{�����[�����k������ɂ́A��Ƀt�@�C���V�X�e�����k�����A���̌�ɘ_���{�����[�����k������K�v������܂��B�t�@�C���V�X�e���̏k���̓}�E���g�����܂܂ł͍s���Ȃ��̂ŁA��ƒ��͈�x�A���}�E���g���Ă����K�v������܂��B

�k���������{�����[�����A���}�E���g���܂��Bumount�R�}���h�����s���āA/mnt/LVMtest���A���}�E���g���܂��B

```
$ sudo umount /mnt/LVMtest
```

�k���������_���{�����[��/dev/Volume00/LogVol01�ɑ΂���fsck�R�}���h�����s���܂��B�����I�Ƀ`�F�b�N���s�����߂�-f�I�v�V������t�^���Ď��s���܂��B

```
$ sudo fsck -f /dev/Volume00/LogVol01
fsck from util-linux 2.37.4
e2fsck 1.46.5 (30-Dec-2021)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/mapper/Volume00-LogVol01: 11/131072 files (0.0% non-contiguous), 17196/524288 blocks
```

resize2fs�R�}���h�����s���āA�t�@�C���V�X�e�����k�����܂��B��Ƃ��āA1GB�܂ŏk�����܂��B

```
$ sudo resize2fs /dev/Volume00/LogVol01 1G
resize2fs 1.46.5 (30-Dec-2021)
Resizing the filesystem on /dev/Volume00/LogVol01 to 262144 (4k) blocks.
The filesystem on /dev/Volume00/LogVol01 is now 262144 (4k) blocks long.
```

lvreduce�R�}���h�����s���āA�_���{�����[��/dev/Volume00/LogVol01���k�����܂��B

```
$ sudo lvreduce -L 1G /dev/Volume00/LogVol01
  File system ext4 found on Volume00/LogVol01.
  File system size (1.00 GiB) is equal to the requested size (1.00 GiB).
  File system reduce is not needed, skipping.
  Size of logical volume Volume00/LogVol01 changed from 2.00 GiB (512 extents) to 1.00 GiB (256 extents).
  Logical volume Volume00/LogVol01 successfully resized.
```

/mnt/LVMtest�ɍă}�E���g���āA�e�ʂ��m�F���܂��B

```
$ sudo mount -t ext4 /dev/Volume00/LogVol01 /mnt/LVMtest
$ df -h /mnt/LVMtest
�t�@�C���V�X                  �T�C�Y  �g�p  �c�� �g�p% �}�E���g�ʒu
/dev/mapper/Volume00-LogVol01   974M   24K  912M    1% /mnt/LVMtest
```


