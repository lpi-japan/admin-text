# �g���u���V���[�e�B���O

## ���O�Ǘ�
�V�X�e����Q�̖��������͂���g���u���V���[�e�B���O���s���ꍇ�ɁA�����Ƃ��L�v�ȏ�񌹂����O�ł��B

���O�ɂ́AOS���o�͂��郍�O�A�A�v���P�[�V�������o�͂��郍�O�ȂǑ����̎�ނ����݂��܂��B

�����ł́A��\�I�ȃ��O�̎�ނƊm�F���@�A�ݒ���@�Ȃǂ�������܂��B

### ���O�̎��
AlmaLinux�ł́A���O�t�@�C����/var/log�f�B���N�g���ȉ��Ɋi�[����Ă��܂��B

�ȉ��͑�\�I�ȃ��O�t�@�C���ł��B

|�t�@�C����|���e|
|-------|-------|
|messages|�T�[�r�X�N�����̏o�͂Ȃǈ�ʓI�ȃ��O|
|secure|�F�؁A�Z�L�����e�B�֌W�̃��O|
|maillog|���[���ԘA�̃��O|
|dmesg|�J�[�l�����o�͂������b�Z�[�W�̃��O|

�܂��Asystemd���L�^����journald�̃��O�����݂��܂��B������͕ʓr������܂��B

### ���O�̊m�F
�T�[�o�[�̃��O�ɃT�[�r�X�N�����A�܂��͓��쎞�̃G���[���O���L�^����Ă��Ȃ������m�F���܂��B�܂��A�N���C�A���g���ɂ��G���[���O���L�^����Ă��Ȃ������m�F���܂��B

* ��ʓI�ȃg���u���ł���΁A�܂���/var/log/messages���m�F���܂��B
* �F�؊֌W��A�N�Z�X�����Ɋ֌W����g���u����/var/log/secure���m�F���܂��B
* ���[���֌W�ł����/var/log/maillog���m�F���܂��B
* Web�T�[�o�[�ł����/var/log/httpd/error_log�Ȃǂ��m�F���܂��B

### dmesg�ɋL�^����郍�O
dmesg�R�}���h�́udisplay message�v�̗��ŁALinux�J�[�l�������b�Z�[�W���o�͂��郊���O�o�b�t�@�i�z�o�b�t�@�j�̓��e��\�����܂��B���̃����O�o�b�t�@�͈��̃T�C�Y���ŏz����悤�ɂȂ��Ă���A�Â����O�͏����Ă����܂��B
dmesg�R�}���h��p���邱�Ƃɂ��A�V�X�e���N�����ɏo�͂����J�[�l�����b�Z�[�W�̊m�F���ł��܂��B�J�[�l�����������n�[�h�E�F�A��F�����Ă��邩�ǂ������m�F����ꍇ�ȂǂɎQ�Ƃ��܂��B

```
$ dmesg
[    0.000000] Linux version 5.14.0-570.26.1.el9_6.x86_64 (mockbuild@x64-builder03.almalinux.org) (gcc (GCC) 11.5.0 20240719 (Red Hat 11.5.0-5), GNU ld version 2.35.2-63.el9) #1 SMP PREEMPT_DYNAMIC Wed Jul 16 09:12:04 EDT 2025
[    0.000000] The list of certified hardware and cloud instances for Red Hat Enterprise Linux 9 can be viewed at the Red Hat Ecosystem Catalog, https://catalog.redhat.com.
[    0.000000] Command line: BOOT_IMAGE=(hd0,gpt2)/vmlinuz-5.14.0-570.26.1.el9_6.x86_64 root=/dev/mapper/almalinux_vbox-root ro crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M resume=/dev/mapper/almalinux_vbox-swap rd.lvm.lv=almalinux_vbox/root rd.lvm.lv=almalinux_vbox/swap rhgb quiet
[    0.000000] [Firmware Bug]: TSC doesn't count with P0 frequency!
[    0.000000] BIOS-provided physical RAM map:
�i���j
```

### syslog�ɂ���
syslog�́A�J�[�l����v���O�����Ȃǂ���o�͂���郍�O���܂Ƃ߂ċL�^����d�g�݂ł��Bsyslog���g�����ƂŁA�e�v���O�����͓Ǝ��Ƀ��O���L�^����d�g�݂��J������K�v�������Ȃ�܂��B�܂��Asyslog�T�[�o�[���l�b�g���[�N��œ��삳���邱�ƂŁA�����̃z�X�g����̃��O���܂Ƃ߂ċL�^���邱�ƂŁA���O���ꌳ�Ǘ����邱�Ƃ��ł��܂��B
AlmaLinux�ł́Asyslog�T�[�o�[�Ƃ���rsyslog���g�p�ł��܂��B

rsyslog�́A�]����syslog�f�[�����isyslogd�j�ɒu�������A�}���`�X���b�h��syslog�f�[�����ł��Brsyslog�iReliable syslog�j�Ƃ������O�����������ʂ�A�����M��������������悤�ɊJ������Ă��܂��B���̂��߁A���O�̓]����TCP���g�p������A�f�[�^�x�[�X�ւ̃��O�ۑ��A�Í����������O�̓]���Ȃǂ��s�����Ƃ��ł��܂��B��{�I�Ȑݒ�ɂ��ẮA�]����syslogd�ƌ݊���������܂��B

### �t�@�V���e�B�ƃv���C�I���e�B
�J�[�l����v���O�������o�͂���syslog���b�Z�[�W�ɂ́A�u�t�@�V���e�B�v�ifacility�j�Ɓu�v���C�I���e�B�v�ipriority�j�ƌĂ΂��l���ݒ肳��Ă��܂��B

�t�@�V���e�B�́A�������̃��O���b�Z�[�W�𐶐������̂����w�肵�܂��B���Ƃ��΁A�J�[�l���⃁�[���Ƃ������l���w�肳��܂��B

�܂��A�v���C�I���e�B�̓��b�Z�[�W�̏d�v�����w�肵�܂��B���Ƃ��΁A�P�Ȃ���A���Ɋ댯�ȏ�ԂȂǂƂ������l���w�肳��܂��B

�t�@�V���e�B�ɂ́A�ȉ��̎�ނ�����܂��B

|�t�@�V���e�B|�Ӗ�|
|-------|-------|
|auth|�Z�L�����e�B�E�F�؊֘A�ilogin�Asu �Ȃǁj|
|authpriv|�Z�L�����e�B�E�F�؊֘A�i�v���C�x�[�g�j|
|cron|cron��at�̃��O|
|daemon|��ʓI�ȃf�[�����i�T�[�o�[�v���O�����j�֘A|
|kern|�J�[�l���֘A|
|lpr|�v�����^�֘A|
|mail|���[���֘A|
|news|NetNews�֘A|
|security|auth�Ɠ���|
|syslog|syslogd���g�̃��O|
|user|���[�U�A�v���P�[�V�����̃��O|
|uucp|uucp�]�����s���v���O�����̃��O|
|local0����local7|�Ǝ��̃v���O�����ŗ��p�\��facility|

�v���C�I���e�B�ɂ́A�ȉ��̎�ނ�����܂��B

|�v���C�I���e�B|�Ӗ�|
|-------|-------|
|debug|�f�o�b�O�p���b�Z�[�W|
|info|��ʓI�ȏ�񃁃b�Z�[�W|
|notice|�ʒm���b�Z�[�W|
|warning|�x�����b�Z�[�W|
|warn|warning�Ɠ���|
|err|��ʓI�ȃG���[���b�Z�[�W|
|error|err�Ɠ���|
|crit|�n�[�h��Q�Ȃǂ̊댯�ȃG���[���b�Z�[�W|
|alert|�V�X�e���j���Ȃǂً̋}����|
|emerg|���Ɋ댯�ȏ��|
|panic|emerg�Ɠ���|
|none|�t�@�V���e�B�𖳌��ɂ���|

### syslog�T�[�o�[�̐ݒ�
syslog�T�[�o�[�̐ݒ�t�@�C���ł���/etc/rsyslog.conf�ɂ́A�󂯎�������O���b�Z�[�W���t�@�V���e�B�ƃv���C�I���e�B�̑g�ݍ��킹�łǂ̃t�@�C���ɏo�͂��邩�̐ݒ肪�L�q����Ă��܂��B

�L�q�͈ȉ��̌`���ƂȂ�܂��B

```
�t�@�V���e�B.�v���C�I���e�B	�A�N�V����
```

syslog�T�[�o�[�̐ݒ�t�@�C�����ŁA�����̃t�@�V���e�B���w�肵�����ꍇ�ɂ́A�u,�v�i�R���}�j�ŋ�؂�܂��B���Ƃ��΁A/var/log/messages�ɂ͗l�X�ȃt�@�V���e�B����̃��O���L�^�����悤�ɐݒ肳��Ă��܂��B���̐ݒ�́A���ׂẴt�@�V���e�B��info�v���C�I���e�B�ȏ�̃��O�����ׂ�/var/log/messages�ɏo�͂���悤�ɂ��Ă��܂��B�������Amail�Aauthpriv�Acron��3�̃t�@�V���e�B�ɂ�none�v���C�I���e�B���w�肳��Ă��邽�߁A�Ώۂ���͏��O����Ă��܂��B

```
*.info;mail.none;authpriv.none;cron.none                /var/log/messages
```

���O���ꂽ�e�t�@�V���e�B�̏o�͂́A�ȉ��̂悤�ɕʓr�w�肳��Ă��܂��B

mail�t�@�V���e�B�̃��O�́A��������ɂ�����x�o�b�t�@�����O������Ń��O�t�@�C���ɏ������ނ悤�Ɂu-�i�n�C�t���j�v���w�肵�Ă��܂��B���[���T�[�o�[�͈�x�ɑ�ʂ̃��O���������ނ��Ƃ���������ł��B

```
authpriv.*						/var/log/secure
mail.*							-/var/log/maillog
cron.*							/var/log/cron
```

### �v���C�I���e�B�̓���
syslog�ݒ�t�@�C�����Ńv���C�I���e�B���w�肷��ƁA���̃v���C�I���e�B�ȏ�̏d�v�x�̃v���C�I���e�B�����ׂē��Ă͂܂�܂��B���Ƃ��΁A�ȉ��̂悤�ɐݒ肵���Ƃ��܂��B

```
mail.warning
```

mail�t�@�V���e�B�����warning�ȏ�ierr�Acrit�Aalert�Aemerg�j�̂��ׂẴv���C�I���e�B�����Ă͂܂�܂��B

����̃v���C�I���e�B�̂ݎw�肵�����ꍇ�ɂ́A�u=�v���C�I���e�B�v�Ǝw�肵�܂��B

```
mail.=warning
```

���̎w���mail�t�@�V���e�B�̃v���C�I���e�B��warning�̃��b�Z�[�W�݂̂����Ă͂܂�܂��B

### �A�N�V�����̐ݒ�
�t�@�V���e�B�ƃv���C�I���e�B���L�q�����E���ɁA�Y�����郍�O���ǂ����邩���w�肷��A�N�V�������L�q���܂��B

��ȃA�N�V�����́A�ȉ��̕\�̂Ƃ���ł��B

#### �t�@�C����
���O���t�@�C���ɏ������ށB

#### -�t�@�C����
���O���t�@�C���ɏ������ލۂɃo�b�t�@�����O����B�������ݐ��\�����シ�邪�A�������܂�Ă��Ȃ��f�[�^�����鎞�ɃV�X�e����Q����������ƃ��O��������B

#### \�v���O����
���O���b�Z�[�W���v���O�����Ɉ����n���B

#### *
���ׂẴ��[�U�̃R���\�[���Ƀ��b�Z�[�W��\������B����A�g�p�ł��Ȃ��Ȃ�\��������܂��B

#### :omusrmsg:*
*���l�ɂ��ׂẴ��[�U�̃R���\�[���Ƀ��b�Z�[�W��\������B����͂�������g�p���邱�Ƃ���������Ă��܂��B

#### @�z�X�g���i���邢��IP�A�h���X�j
UDP��syslog�T�[�o�[�Ƀ��O���b�Z�[�W�𑗐M����B

#### @@�z�X�g���i���邢��IP�A�h���X�j
TCP��syslog�T�[�o�[�Ƀ��O���b�Z�[�W�𑗐M����B

### �J�[�l�����O��syslog�o�͐ݒ�
�f�t�H���g�̐ݒ�ł̓R�����g�A�E�g����Ė����ɂȂ��Ă���J�[�l������̃��O�o�͂̐ݒ��L���ɂ��܂��B�J�[�l���̃��O�́A���Ƃ���nftables�ɂ��p�P�b�g�t�B���^�����O�̂悤�ȃJ�[�l���̋@�\�����O���o�͂��܂��B

firewalld�̐ݒ��ύX���āA���ۂ����ʐM�����ׂă��O�o�͂���悤�ɕύX���܂��B

```
$ sudo firewall-cmd --get-log-denied
off
$ sudo firewall-cmd --set-log-denied=all
success
$ sudo firewall-cmd --get-log-denied
all
$ sudo firewall-cmd --reload
success
```

���̏�Ԃł́A�J�[�l������̃��O�o�͂͂��ׂ�/var/log/messages�ɋL�^����܂��B/etc/rsyslog.conf��ҏW���A�t�@�V���e�B��kern�A�v���C�I���e�B���S�Ẵ��b�Z�[�W��/var/log/kern.log�ɏo�͂���ݒ��ǉ����܂��B

```
$ sudo vi /etc/rsyslog.conf

# Log all kernel messages to the console.
# Logging much else clutters up the screen.
#kern.*                                                 /dev/console
kern.*                                                 /var/log/kern.log
```

rsyslog�T�[�r�X���ċN�����āA�V�����ݒ��ǂݍ��܂��܂��B

```
$ sudo systemctl restart rsyslog
```

�O���̃z�X�g����ݒ���s�����z�X�g�ɑ΂��āAnftables�ŋ�����Ă��Ȃ��|�[�g�ԍ�80�Ԃ�443�Ԃ�Web�u���E�U���ŃA�N�Z�X���܂��B

/var/log/kern.log�Ƀ|�[�g�ԍ�80�Ԃɑ΂���ʐM�����ۂ����|�̃��O���o�͂���܂��BDPT������̃|�[�g�ł��B

```
$ sudo tail /var/log/kern.log 
Jul 19 19:21:07 vbox kernel: filter_IN_public_REJECT: IN=enp0s8 OUT= MAC=08:00:27:40:b7:96:d0:11:e5:1a:ce:3b:08:00 SRC=192.168.11.115 DST=192.168.11.108 LEN=64 TOS=0x00 PREC=0x00 TTL=64 ID=0 DF PROTO=TCP SPT=62290 DPT=80 WINDOW=65535 RES=0x00 CWR ECE SYN URGP=0
Jul 19 19:21:07 vbox kernel: filter_IN_public_REJECT: IN=enp0s8 OUT= MAC=08:00:27:40:b7:96:d0:11:e5:1a:ce:3b:08:00 SRC=192.168.11.115 DST=192.168.11.108 LEN=64 TOS=0x00 PREC=0x00 TTL=64 ID=0 DF PROTO=TCP SPT=62291 DPT=443 WINDOW=65535 RES=0x00 CWR ECE SYN URGP=0
```

### �����[�g�z�X�g�̃��O��UDP�Ŏ󂯎��
syslog�T�[�o�[�Ƃ��ă����[�g�z�X�g�̃��O���󂯎�邽�߂̐ݒ���s���܂��Bsyslog�̃��b�Z�[�W�̑���M�́A�ʏ�UDP�ōs���܂��B

�ݒ�t�@�C��/etc/rsyslog.conf���ɂ���ȉ���2�s����A�s���̃R�����g�A�E�g���폜���Đݒ��L���ɂ��܂��B

module(load="imudp")�́AUDP�p�̃v���g�R�����W���[���̃��[�h��ݒ肵�Ă��܂��Binput(type="imudp" port="514")�́AUDP�Ń��O���b�Z�[�W���󂯎��|�[�g�ԍ���514�ԂƂ��Ďw�肵�Ă��܂��B

```
$ sudo vi /etc/rsyslog.conf
```

```
�i���j
# Provides UDP syslog reception
module(load="imudp") # needs to be done just once
input(type="imudp" port="514")
```

rsyslog�T�[�r�X���ċN�����܂��Brsyslogd��UDP�̃|�[�g�ԍ�514�Ԃő҂��󂯂�悤�ɂȂ�܂��B

```
$ sudo systemctl restart rsyslog
$ ss -uln | grep 514
UNCONN 0      0                                0.0.0.0:514        0.0.0.0:*
UNCONN 0      0                                   [::]:514           [::]:*
```

�ݒ��Afirewalld�̐ݒ��ύX���A�O�������UDP�̃|�[�g�ԍ�514�Ԃւ̃p�P�b�g��������悤�ɐݒ��ύX����K�v������܂��B�ݒ�ɂ��Ă͌�q���܂��B

### �����[�g�z�X�g�̃��O��TCP�Ŏ󂯎��
���O���b�Z�[�W�̑���M��TCP���g�p���邱�Ƃɂ��AUDP�Ŕ������Ă������O�̎�肱�ڂ���h�����Ƃ��ł��܂��BUDP�̓Z�b�V�������X�ȃv���g�R���̂��߁A����M�Ɏ��s�������ɍđ��M����d�g�݂��������߂ł��B

�������ATCP�̓v���g�R���̐�����UDP�����������d���Ȃ��Ă��܂����߁A��ʂ̃��O�����M����Ă�����ł͋t�Ƀ{�g���l�b�N�ɂȂ��Ă��܂��Asyslog�T�[�o�[���������ׂŏ������؂��Ă��܂��\��������܂��B

���̂��߁ATCP���g�������O���b�Z�[�W�̑���M�́A���O�̗ʂ�����قǑ����Ȃ����O�L�^�̐M�������K�v�ȏꍇ�ɐݒ肵�܂��B�����A��ʂ̃��O�����M����Ă���ꍇ�ɂ́Asyslog�T�[�o�[�𕡐��p�ӂ��邩�AUDP���g���K�v������܂��B

�ݒ�t�@�C��/etc/rsyslog.conf���ɂ���ȉ���2�s����A�s���̃R�����g�A�E�g���폜���Đݒ��L���ɂ��܂��B

module(load="imtcp")�́ATCP�p�̃v���g�R�����W���[���̃��[�h��ݒ肵�Ă��܂��Binput(type="imtcp" port="514")�́ATCP�Ń��O���b�Z�[�W���󂯎��|�[�g�ԍ���514�ԂƂ��Ďw�肵�Ă��܂��B

```
$ sudo vi /etc/rsyslog.conf
```

```
�i���j
# Provides TCP syslog reception
module(load="imtcp") # needs to be done just once
input(type="imtcp" port="514")
```

rsyslog�T�[�r�X���ċN�����܂��Brsyslogd��TCP�̃|�[�g�ԍ�514�Ԃő҂��󂯂�悤�ɂȂ�܂��B

```
$ sudo systemctl restart rsyslog
$ ss -tln | grep 514
LISTEN 0      25           0.0.0.0:514       0.0.0.0:*
LISTEN 0      25              [::]:514          [::]:*
```

�ݒ��Afirewalld�̐ݒ��ύX���A�O�������TCP�̃|�[�g�ԍ�514�Ԃւ̃p�P�b�g��������悤�ɐݒ��ύX����K�v������܂��B

### syslog�T�[�o�[�̂��߂�firewalld�̐ݒ�
firewalld�̐ݒ��ύX���ATCP�����UDP�̃|�[�g�ԍ�514�Ԃ̐ڑ��������Ă����܂��B


```
sudo firewall-cmd --add-port=514/udp --permanent
sudo firewall-cmd --add-port=514/tcp --permanent
sudo firewall-cmd --reload
```

### syslog�N���C�A���g�̐ݒ�
�l�b�g���[�N�Őڑ����ꂽsyslog�T�[�o�[�ɑ΂��ă��O���b�Z�[�W�𑗐M����syslog�N���C�A���g��ݒ肵�܂��B

syslog�N���C�A���g���̃z�X�g�ł�rsyslog��ݒ肵�A�A�N�V�����̐ݒ�Ńl�b�g���[�N���syslog �T�[�o�[���w�肵�܂��B

syslog�N���C�A���g�̐ݒ�t�@�C��/etc/rsyslog.conf���C�����܂��B

authpriv�t�@�V���e�B�Ɋւ��邷�ׂẴ��O��syslog�T�[�o�[�ɑ��M����悤�ɐݒ��ǉ����܂��B@���M��Ǝw�肷�邱�Ƃ�UDP���g�p�������M���w��ł��܂��B

�܂��Amail�t�@�V���e�B�Ɋւ��邷�ׂẴ��O��syslog�T�[�o�[�ɑ��M����悤�ɐݒ��ǉ����܂��B@@���M��Ǝw�肷�邱�Ƃ�TCP���g�p�������M���w��ł��܂��B

```
$ sudo vi /etc/rsyslog.conf
```

```
# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure
authpriv.*                                              @192.168.56.101

# Log all the mail messages in one place.
mail.*                                                  -/var/log/maillog
mail.*                                                  @@192.168.56.101
```

syslog�N���C�A���g��rsyslog�T�[�r�X���ċN�����܂��B

```
$ sudo systemctl restart rsyslog
```

#### UDP�Ń��O�𑗐M
syslog�N���C�A���g��logger�R�}���h�����s���āAauthpriv.debug�v���C�I���e�B�Ń��O���o�͂��܂��B

```
[linuc@client ~]$ logger -p authpriv.debug "This is auth log over UDP"
```

syslog�T�[�o�[���/var/log/secure�Ƀ��O���o�͂���邱�Ƃ��m�F���܂��B

```
[linuc@server ~]$ sudo tail -f /var/log/secure 
�i���j
Jul 27 15:16:44 vbox linuc[3207]: This is auth log over UDP
```

#### TCP�Ń��O�𑗐M
syslog�N���C�A���g��logger�R�}���h�����s���āAmail.debug�v���C�I���e�B�Ń��O���o�͂��܂��B

```
[linuc@client ~]$ logger -p mail.debug "This is mail log over TCP"
```

syslog�T�[�o�[���/var/log/maillog�Ƀ��O���o�͂���邱�Ƃ��m�F���܂��B

```
[linuc@server ~]$ sudo tail /var/log/maillog
Jul 27 15:17:48 vbox linuc[3209]: This is mail log over TCP
```

### logrotate�ɂ�郍�O���[�e�[�V����
���O�t�@�C���͏�ɒǋL����Ă������߁A�t�@�C���T�C�Y������ɔ�剻���ăf�B�X�N�e�ʂ��������A��Ń��O���m�F����ۂɕK�v�ȃ��O�������ɂ����Ȃ�܂��B�����̖���������邽�߁A���O�������ԂŃ��[�e�[�V��������logrotate���g���Ă��܂��B

logrotate�́Asystemd timer����1��1��N������܂��B/etc/logrotate.conf��logrotate�̐ݒ�t�@�C���ƂȂ��Ă���A���O�t�@�C�������[�e�[�V��������^�C�~���O��A���O�t�@�C����������܂Ŏc�����Ȃǂ̐ݒ肪�L�q����Ă��܂��B�T�[�r�X���̏ڍׂȐݒ�́A/etc/logrotate.d�f�B���N�g���Ɋi�[����Ă��܂��B

logrotate�̐ݒ�Ŏg�p�ł���f�B���N�e�B�u�͈ȉ��̂Ƃ���ł��B

#### create [���[�h] [���L���[�U] [���L�O���[�v]
���[�e�[�V�������s������A����ɋ�̐V�K���O�t�@�C�����쐬���܂��B�������w��ł��܂��B���[�h��0755�̂悤�Ȑ��l�����B�w�肵�Ȃ������ɂ��Ă͌��̃t�@�C���̑����������p����܂��B

#### nocreate
create���O���[�o���ɐݒ肵���ꍇ�ɁA�ʂ�create�𖳌��ɂ������ۂɎg�p���܂��B

#### copy/nocopy
���̃��O�t�@�C���͂��̂܂܂ɂ��āA�R�s�[��ۑ����܂��B

#### copytruncate/nocopytruncate
copy�̓�����s������A���̃��O�t�@�C���̓��e���������܂��B�������I�ɂ�create�Ɠ������ʂƂȂ�܂��B����̓��O�t�@�C���������[�h������@�������v���O�����ւ̑Ώ��@�̂ЂƂł��B���Ƃ���Oracle 10g R1/R2��alert���O�ɑ΂��ẮA���̕��@���s��Ȃ��ƈȑO�̃��O�t�@�C���i�Ⴆ��alert_xx.log.1�j�Ƀ��O���������ݑ������܂��B

#### rotate ���㐔
���ネ�[�e�[�V�����̐��㐔���w�肵�܂��B���Ƃ��Ό��̃��O�t�@�C����a.log�̏ꍇ�Anum��2���w�肷��ƁAa.log��a.log.1��a.log.2���p���ƂȂ�܂��B0�̏ꍇ�Aa.log���p���ƂȂ�܂��B

#### start ���l
�ŏ��̃��[�e�[�V�����t�@�C���̖����ɕt������l���w�肵�܂��B�f�t�H���g��1�ł��B���Ƃ���num��5���w�肷��ƁAa.log��a.log.5��a.log.6�ƂȂ�܂��B

#### extension �g���q
���[�e�[�V�������������O�t�@�C���ɕt����g���q���w�肵�܂��B�w��ɂ͋�؂�̃h�b�g���K�v�ł��B���Ƃ��Ίg���q�Ɂu.bak�v�Ǝw�肷��ƁAsome.log�̏��ネ�[�e�[�V�������O��some.log.1.bak�ƂȂ�܂��B���k���s���ꍇ�A���k�ɂ��g���q�͂���ɂ��̌��ɕt���܂��B

#### compress/nocompress
���[�e�[�V����������̋��t�@�C���Ɉ��k���|���܂��B�f�t�H���g��nocompress�i�񈳏k�j�ł��B

#### compresscmd �R�}���h
���O�t�@�C���̈��k�Ɏg�p����v���O�������w�肵�܂��B�f�t�H���g��gzip�ł��B

#### uncompresscmd �R�}���h
���O�t�@�C���̉𓀂Ɏg�p����v���O�������w�肵�܂��B�f�t�H���g��gunzip�ł��B

#### compressoptions �I�v�V����
���k�v���O�����֓n���I�v�V�������w�肵�܂��B�f�t�H���g��gzip�ɓn���u-9�v�i���k���ő�j�ł��B�u-9 -s�v�̂悤�ɃX�y�[�X����ŕ����̃I�v�V�������w�肷�邱�Ƃ͂ł��܂���B

#### compressext �g���q
���k��̃t�@�C���ɕt����g���q�i�h�b�g���K�v�j���w�肵�܂��B�f�t�H���g�ł́A�g�p���鈳�k�R�}���h�ɉ��������̂��t�����܂��B

#### delaycompress/nodelaycompress
���k���������̃��[�e�[�V�����܂Œx�点��A���邢�͒x�点�܂���B

#### olddir �f�B���N�g��/noolddir
���[�e�[�V�������������O���f�B���N�g���Ɉړ����܂��B�ړ���͌��Ɠ����f�o�C�X��Ŏw�肵�܂��B���̃��O�ɑ΂��鑊�Ύw����L���ł��B

#### mail address/nomail
�����O�t�@�C����address�ɑ��M���܂��B�ǂ̒i�K�̃��O�𑗂邩��maillast�Ȃǂ̃I�v�V�����Ō��܂�܂��B

#### maillast
���オ�I����Ĕj������郍�O�����[�����܂��B

#### mailfirst
���ネ�[�e�[�V�������O�����[�����܂��B

#### daily/weekly/monthly
���O���[�e�[�V���������/�T��/�����ɍs���܂��B�f�t�H���g��daily�B���Ƃ���weekly�Ȃ�A�������s�����Ƃ��Ă��A�T��1�񂾂����[�e�[�V�������s���܂��B

#### size �T�C�Y[K/M]
���O�̃T�C�Y���T�C�Y�o�C�g�𒴂��Ă���΃��[�e�[�V�������s���܂��B���̏�����daily,weekly�Ȃǂ̏������D�悳��܂��B�L���o�C�g�iK�j�A���K�o�C�g�iM�j�ł̎w����ł��܂��B

#### ifempty/notifempty
���̃��O�t�@�C������ł����[�e�[�V�������s���A���邢�͍s���܂���B

#### missingok/nomissingok
�w��̃��O�t�@�C�������݂��Ȃ������Ƃ��Ă��G���[���o�����ɏ����𑱍s����A���邢�̓G���[���o�͂��܂��B

#### firstaction
���[�e�[�V�������s���O�ɃX�N���v�g�����s���܂��Bprerotete�����O�Ɏ��s�����ʒ�`���ł̂ݎw��\�ł��B

#### prerotate
���[�e�[�V�������s���O�ɃX�N���v�g�����s���܂��Bfirstaction�̌�Ɏ��s����܂��B�ʒ�`���ł̂ݎw��ł��܂��B

#### postrotate
���[�e�[�V�������s��ꂽ��ɃX�N���v�g�����s���܂��Blastaction���O�Ɏ��s����܂��B�ʒ�`���ł̂ݎw��ł��܂��B

#### lastaction
���[�e�[�V�������s��ꂽ��i������j�ɃX�N���v�g�����s���܂��Bpostrotate�̌�Ɏ��s����܂��B�ʒ�`���ł̂ݎw��ł��܂��B

#### sharedscripts
���[�e�[�V�������郍�O�������������ꍇ�ɁAprerotate�Apostrotate�̃X�N���v�g����x�������s���܂��B

#### nosharedscripts
���[�e�[�V�������郍�O�������������ꍇ�ɁAprerotate�Apostrotate�̃X�N���v�g���e���O�t�@�C�����Ɏ��s���܂��B

#### include �t�@�C���i�f�B���N�g���j
include�̋L�q�̂���ʒu�ɕʂ̐ݒ�t�@�C����ǂݍ��݂܂��B�f�B���N�g�����w�肵���ꍇ�A���̃f�B���N�g��������A�f�B���N�g������і��O�t���p�C�v�ȊO�̒ʏ�t�@�C�����A���t�@�x�b�g���ɓǂݍ��܂�܂��B

#### tabooext [+] �g���q[,�g���q,...]
include�Ńf�B���N�g�����w�肵���ꍇ�ɓǂݍ��ރt�@�C�����珜�O����t�@�C���̊g���q���w�肵�܂��B�f�t�H���g�Łu.rpmorig�v�u.rpmsave�v�u,v�v�u.swp�v�u.rpmnew�v�u~�v�u.cfsaved�v�u.rhn-cfg-tmp-*�v���w�肳��Ă��܂��B+���w�肷��ƃf�t�H���g�w��ɑ΂��Ēǉ��Ŋg���q���w��ł��܂��B+���w�肵�Ȃ��ƃf�t�H���g�w���j�����ĐV�K�Ɋg���q���w�肵�܂��B

�����ɏЉ���ȊO�̃f�B���N�e�B�u����������̂ŁA�}�j���A�������Q�Ƃ��Ă݂Ă��������B

### ���O���[�e�[�g�ݒ�t�@�C���̊m�F
/etc/logrotate.d/httpd���Q�l�ɁA���[�e�[�g�̐ݒ���m�F���܂��B

```
$ cat /etc/logrotate.d/httpd 
# Note that logs are not compressed unless "compress" is configured,
# which can be done either here or globally in /etc/logrotate.conf.
/var/log/httpd/*log {
    missingok
    notifempty
    sharedscripts
    delaycompress
    postrotate
        /bin/systemctl reload httpd.service > /dev/null 2>/dev/null || true
    endscript
}
```

���̗�ł́A�ȉ��̒ʂ胍�O���[�e�[�V�����̏������s���܂��B

�ΏۂƂȂ郍�O�t�@�C����/var/log/httpd�f�B���N�g�����́A�t�@�C������log�ŏI��邷�ׂẴ��O�t�@�C���ł��B�f�t�H���g�ł�access_log�Aerror_log�Ƃ����t�@�C�����̃��O�t�@�C�����쐬����Ă��܂��B

* 1�s�ڂ�missingok�Ń��O�t�@�C�������݂��Ȃ������Ƃ��Ă��G���[���o�����ɏ����𑱍s���܂��B
* 2�s�ڂ�notifempty�Ō��̃��O�t�@�C������Ȃ�΃��[�e�[�V�������܂���B
* 3�s�ڂ�sharedscripts��prerotate,postrotate �̃X�N���v�g����x�������s���܂��B
* 4�s�ڂ�delaycompress�ň��k���������̃��[�e�[�V�����܂Œx�点�܂��B
* 5�s�ڂ�"postrotate"����"endscript"�܂ł��A���[�e�[�V�������s��ꂽ��Ɏ��s�����X�N���v�g�ł��Bsystemctl�R�}���h�����s����httpd�T�[�r�X��reload���邱�ƂŁA�V�������O�t�@�C������������܂��B

## journald�̃��O�̊m�F
journald�̃��O���m�F����ɂ́Ajournalctl�R�}���h�����s���܂��B�I�v�V������t�^���Ȃ��Ŏ��s����ƁA���ׂẴ��O���\������܂��B

�ȉ��̗�ł́ALinux�J�[�l���N�����̃��O���L�^����Ă���̂�������܂��B

```
$ journalctl
 7�� 19 21:48:50 localhost kernel: Linux version 5.14.0-570.12.1.el9_6.x86_64 (mockbuild@x64-builder02.almalinux.org) (gcc (GCC) 11.5.0 >
 7�� 19 21:48:50 localhost kernel: The list of certified hardware and cloud instances for Red Hat Enterprise Linux 9 can be viewed at th>
 7�� 19 21:48:50 localhost kernel: Command line: BOOT_IMAGE=(hd0,gpt2)/vmlinuz-5.14.0-570.12.1.el9_6.x86_64 root=/dev/mapper/almalinux_v>
 7�� 19 21:48:50 localhost kernel: [Firmware Bug]: TSC doesn't count with P0 frequency!
 7�� 19 21:48:50 localhost kernel: BIOS-provided physical RAM map:
�i���j
```


����̃T�[�r�X�̃��O�ɍi��ɂ́A-u�I�v�V������t�^���Ď��s���܂��B

�ȉ��̗�ł́Ahttpd�T�[�r�X�N�����̃��O���m�F�ł��܂��B

```
# journalctl -u httpd
 7�� 26 18:40:34 vbox systemd[1]: Starting The Apache HTTP Server...
 7�� 26 18:40:34 vbox httpd[2412]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using fe80::a0>
 7�� 26 18:40:34 vbox systemd[1]: Started The Apache HTTP Server.
 7�� 26 18:40:34 vbox httpd[2412]: Server configured, listening on: port 80
�i���j
```

### journald�̃��O�̕ۑ�
journald�̃��O�́A�ċN������Ə����Ă��܂��ݒ肪�f�t�H���g�ƂȂ��Ă��܂��Bjournald�̐ݒ�t�@�C��/etc/systemd/journald.conf��Storage�ݒ�̒l���f�t�H���g�ł�auto�ɐݒ肳��Ă��܂��B���̐ݒ�́A�ȉ��̂悤�ɓ��삵�܂��B

1. /var/log/journal�f�B���N�g�������݂���Ώ�������
1. /var/log/journal�f�B���N�g�������݂��Ȃ����A�������߂Ȃ��ꍇ�ɂ́A/run/log/journal�f�B���N�g���ɏ�������

�f�t�H���g�ł�/var/log/journal�f�B���N�g���͑��݂��Ȃ����߁A/run/log/journal�f�B���N�g���Ƀ��O���������܂�܂��B/run/log/journal�f�B���N�g����tmpfs�Ń�������ɍ��ꂽ�ꎞ�̈�Ȃ̂ŁA�V�X�e���ċN�����Ƀ��O�̃t�@�C���͏����Ă��܂��܂��B

journald�̃��O���V�X�e���ċN�����ɏ����Ȃ��悤�ɂ���ɂ́A�ȉ��̂悤��/var/log/journal�f�B���N�g�����쐬���āA�V�X�e�����ċN�����܂��B

```
# mkdir /var/log/journal
# chmod 700 /var/log/journal
# reboot
```

���O�t�@�C�����쐬���ꂽ���Ƃ��m�F���܂�

```
$ ls -l /var/log/journal
���v 0
drwxr-sr-x+ 2 root systemd-journal 53  7�� 27 15:24 65dd8a0b080e4373a5633404cabaac84
$ ls -l /var/log/journal/65dd8a0b080e4373a5633404cabaac84
���v 16388
-rw-r-----+ 1 root systemd-journal 8388608  7�� 27 15:24 system.journal
-rw-r-----+ 1 root systemd-journal 8388608  7�� 27 15:24 user-1000.journal
```

## �l�b�g���[�N�c�[�����g�����g���u���V���[�e�B���O
�T�[�o�[�ɐڑ��ł��Ȃ��Ȃǃl�b�g���[�N�ɋN�������肪���������ꍇ�A��{�I�Ȍ����̒������s�����߂̃c�[���Ƃ��āA�ȉ��̂悤�ȃl�b�g���[�N�c�[�����g�p���܂��B

* ping
* traceroute
* netstat
* tcpdump
* Wireshark

�����̃c�[�����g�p�����A�g���u���V���[�e�B���O�ɂ��ĉ�����܂��B��ʓI�ɂ́A�O������T�[�r�X�ւ̐ڑ����ł��Ȃ��Ȃ����ꍇ�ɂ́A�ȉ��̂悤�Ȏ菇�Ō����̒������s���܂��B

1. ���O�̊m�F
1. ping�R�}���h�ɂ��IP�ʐM�̊m�F
1. netstat�R�}���h�ɂ��|�[�g�̏󋵂̊m�F
1. �ʐM���e�̊m�F

### ping�R�}���h�ɂ��IP�ʐM�̊m�F
ping�R�}���h���g���āA�T�[�o�[�ɑ΂���ʐM���s���邩�ǂ������m�F���܂��Bping�R�}���h��ICMP���g�����ʐM��IP�ʐM���\���m�F�ł��܂��B�T�[�o�[�ɑ΂���ping�ɉ����������ꍇ�A�ȉ��̂悤�Ȗ�肪�l�����܂��B

#### ping�R�}���h�ɉ������Ȃ��T�[�o�[���g�̖��
IP�A�h���X��f�t�H���g�Q�[�g�E�F�C���K�؂ɐݒ肳��Ă��Ȃ�������Afirewalld�Ȃǂ̃p�P�b�g�t�B���^�����O��ICMP��ʂ��Ȃ��ݒ�ɂȂ��Ă��邱�Ƃ��l�����܂��B
�T�[�o�[�̃l�b�g���[�N�ݒ���ēx�m�F���Ă݂܂��B�܂��A�T�[�o�[�����瑼�̃z�X�g��ping�R�}���h�����s���āA���������邩�m�F���Ă݂܂��B

#### �l�b�g���[�N�o�H�̖��
�l�b�g���[�N�ʐM�o�H��ɂ���P�[�u����X�C�b�`�A���[�^�[�A�t�@�C�A�[�E�H�[���⃍�[�h�o�����T�[�Ȃǂ̃l�b�g���[�N�@��ɖ�肪���������m�F���܂��B
���[�e�B���O�ɖ�肪���邩���m�F���邽�߂ɂ�traceroute�R�}���h���g�p���܂����Atraceroute�R�}���h��ICMP���g�p���Ă��邽�߁A�r���̃��[�^�[��ICMP��ʂ��Ȃ��ꍇ�A���ׂĂ̌o�H���m�F�ł��Ȃ����Ƃ�����܂��B

### �T�[�o�[�ɐڑ��ł��Ȃ����̉���
ping�R�}���h�ɂ�鉞�������邪�A�T�[�o�[�ɐڑ��ł��Ȃ��ꍇ�ɂ́A�l�b�g���[�N�o�H���T�[�o�[���g�̃p�P�b�g�t�B���^�����O�A�T�[�o�[���ł̃|�[�g�o�C���f�B���O�̖��Ȃǂ��l�����܂��B

#### �T�[�o�[�ɐڑ��ł��Ȃ��l�b�g���[�N�o�H�̖��
firewalld��l�b�g���[�N�o�H��̃t�@�C�A�[�E�H�[���ȂǂŁA�w�肳�ꂽ�|�[�g�ւ̒ʐM��������Ă��Ȃ��B
firewalld��t�@�C�A�[�E�H�[���̃|�[�g���ݒ���m�F���܂��B

#### �T�[�o�[�ɐڑ��ł��Ȃ��T�[�o�[���g�̖��
�T�[�r�X����~���Ă���A�w�肳�ꂽ�|�[�g��Listen���Ă��Ȃ��B���邢�́A���[�J�����[�v�o�b�N�A�h���X�i127.0.0.1�j�̂�Listen���Ă���A�ڑ���Ɏw�肵��IP�A�h���X�Ƀ|�[�g���o�C���h����Ă��Ȃ��B
ss�R�}���h�Ȃǂ��g�p���āA�|�[�g�̏�Ԃ��m�F���܂��B

#### ss�R�}���h�ł̃|�[�g�̏󋵂̊m�F
ss�R�}���h���g���āA�T�[�r�X�v���Z�X�ƃ|�[�g�ԍ��A�����IP�A�h���X�Ƃ̃o�C���h�̏󋵂��m�F�ł��܂��B

ss�R�}���h��-p�I�v�V�������w�肵�Ď��s���܂��B

```
$ sudo ss -tlp | grep ssh
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=968,fd=3))
LISTEN 0      128             [::]:22           [::]:*    users:(("sshd",pid=968,fd=4))
```

���̌��ʂ���A�ȉ��̂��Ƃ�������܂��B

* sshd�̃v���Z�XID��968�ł��邱��
* TCP�|�[�g�ԍ�22�Ԃ�LISTEN���Ă��邱��
* �|�[�g�ԍ�22�Ԃ��T�[�o�[�̂��ׂĂ�IP�A�h���X�i0.0.0.0:22/[::]:22�j�Ƀo�C���h����Ă��邱��
* ���M���������s���Ă��Ȃ����Ɓi0.0.0.0:*/[::]:*�j

### �p�P�b�g�L���v�`���ɂ��ʐM���e�̊m�F
�T�[�o�[�Ƃ̐ڑ����s���Ă���A���O�ɂ��肪����ƂȂ�G���[���������A�T�[�r�X�����������삵�Ȃ��悤�ȏꍇ�ɂ́A�ʐM�p�P�b�g���L���v�`�����āA�ʐM���e���m�F���܂��B�p�P�b�g���L���v�`�����邱�ƂŁA�T�[�o�[�ƃN���C�A���g�̊Ԃłǂ̂悤�ȒʐM���s���Ă��邩���m�F�ł��܂��B
�p�P�b�g�L���v�`���̃c�[���Ƃ��ẮAGUI�ő���ł���Wireshark�Ȃǂ�����܂��B

#### Wireshark���g�����m�F
GUI�����p�P�b�g�L���v�`�������O�\�t�g�ł���Wireshark���g���΁A�p�P�b�g�L���v�`�������O���s�����p�P�b�g�̒��g��������A�t�B���^�����O�@�\�ŕK�v�ȃp�P�b�g�݂̂ɍi�荞��Ńp�P�b�g���m�F���邱�Ƃ��ł��܂��B

Wireshark���C���X�g�[�����܂��B

```
$ sudo dnf install wireshark
```

1. Wireshark���N�����܂��B
AlmaLinux��GUI�Ń��O�C�����A�[������wireshark�R�}���h�����s���܂��B�p�P�b�g�L���v�`���ɂ�root�������K�v�Ȃ̂ŁAsudo�R�}���h�Ŏ��s���܂��B

```
$ sudo wireshark
```

��2

2. �L���v�`�����s���f�o�C�X��I�т܂��B

![�uCapture�v���j���[���uInterfaces�v��I�����܂�](wireshark1.png)

�C���^�[�t�F�[�X�̈ꗗ����p�P�b�g�L���v�`�����s�������C���^�[�t�F�[�X���N���b�N���đI�����܂��B���������ɑI���������ꍇ�ɂ̓}�E�X�̍��{�^���������Ȃ���h���b�O���ĕ����I�����܂��B
�A�N�Z�X�e�X�g��Web�T�[�o�[�����삵�Ă���Linux���Web�u���E�U���g���ꍇ�A�g�p����C���^�[�t�F�[�X��Loopback:lo�ɂȂ�_�ɒ��ӂ��Ă��������B

��3

3. �p�P�b�g�L���v�`�����J�n���܂��B

![eth0��I�����܂�](wireshark2.png)

�I�������C���^�[�t�F�[�X���E�N���b�N���āu�L���v�`���J�n�v��I�����܂��B
�C���^�[�t�F�[�X���_�u���N���b�N�ł��L���v�`�����J�n�ł��܂��B

��4

4. Web�T�[�o�[�ɃA�N�Z�X���܂��B
�T�[�o�[�ƒʐM���s���ăp�P�b�g�L���v�`�����s���܂��B�N���C�A���g��Web�u���E�U���N�����A�T�[�o�[��Web�T�[�o�[�ɃA�N�Z�X���܂��B

��5

5. �p�P�b�g�L���v�`�����~���܂��B
�u�L���v�`���v���j���[���u��~�v��I�����A�p�P�b�g�L���v�`�����~���܂��B
����̐Ԃ��l�p����~�{�^���ł���~�ł��܂��B

��6

6. ���ʂ̍i�荞�݂��s���܂��B

![http�ōi�荞�݂��s���܂�](wireshark3.png)

�uFilter:�v�̃e�L�X�g�{�b�N�X�Ɂuhttp�v�Ɠ��͂��āAEnter�L�[�������či�荞�݂܂��B
�Q�Ƃ������p�P�b�g��I�����A�E�C���h�E�^�񒆂̏ڍ׏��ŁuHypertext Transfer Protocol�v���_�u���N���b�N���āAHTTP�ʐM�̓��e���m�F���܂��B
