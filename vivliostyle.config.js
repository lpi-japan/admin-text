module.exports = {
  title: 'Linuxシステム管理標準教科書',
  author: 'LPI-Japan',
  language: 'ja',
  size: 'A4',
  theme: '@vivliostyle/theme-techbook',
  css: 'fonts.css',
  entry: [
    '0preface.md',
    '1user.md',
    '2network.md',
    '3service.md',
    '4filesystem.md',
    '5system.md',
    '6troubleshoot.md',
    '7CentOS7.md'
  ],
  output: [
    './output/linux-system-admin-textbook.pdf',
    {
      path: './output/linux-system-admin-textbook-web',
      format: 'webpub'
    }
  ],
  workspaceDir: './output',
  toc: true,
  cover: undefined,
  vfm: {
    hardLineBreaks: true,
    disableFormatHtml: true
  }
};