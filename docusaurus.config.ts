import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Novyx Docs',
  tagline: 'Persistent memory, rollback, and eval for AI agents',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://docs.novyxlabs.com',
  baseUrl: '/',

  organizationName: 'novyxlabs',
  projectName: 'novyx-docs',

  onBrokenLinks: 'warn',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  themes: [
    '@docusaurus/theme-live-codeblock',
    [
      '@easyops-cn/docusaurus-search-local',
      {
        hashed: true,
        language: ['en'],
        highlightSearchTermsOnTargetPage: true,
        explicitSearchResultPath: true,
        docsRouteBasePath: '/',
        indexBlog: false,
      },
    ],
  ],

  scripts: [
    {
      src: 'https://plausible.io/js/pa-kYOApNHVLUYe_Ur3AHAA_.js',
      async: true,
    },
  ],

  headTags: [
    {
      tagName: 'script',
      attributes: {},
      innerHTML: `window.plausible=window.plausible||function(){(plausible.q=plausible.q||[]).push(arguments)},plausible.init=plausible.init||function(i){plausible.o=i||{}};plausible.init()`,
    },
  ],

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          editUrl: 'https://github.com/novyxlabs/novyx-docs/tree/main/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    image: 'img/og-image.png',
    colorMode: {
      defaultMode: 'dark',
      disableSwitch: false,
      respectPrefersColorScheme: false,
    },
    navbar: {
      title: 'Novyx',
      logo: {
        alt: 'Novyx Logo',
        src: 'img/logo.svg',
      },
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          to: '/api-reference',
          label: 'API Reference',
          position: 'left',
        },
        {
          to: '/sdks',
          label: 'SDKs',
          position: 'left',
        },
        {
          to: '/changelog',
          label: 'Changelog',
          position: 'left',
        },
        {
          href: 'https://www.novyxlabs.com',
          label: 'novyxlabs.com',
          position: 'right',
        },
        {
          href: 'https://github.com/novyxlabs',
          label: 'GitHub',
          position: 'right',
        },
        {
          href: 'https://novyxlabs.com/pricing',
          label: 'Get Free API Key',
          position: 'right',
          className: 'navbar__link--cta',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            { label: 'Getting Started', to: '/' },
            { label: 'API Reference', to: '/api-reference' },
            { label: 'SDKs', to: '/sdks' },
          ],
        },
        {
          title: 'Product',
          items: [
            { label: 'Novyx Core', href: 'https://www.novyxlabs.com' },
            { label: 'Pricing', href: 'https://www.novyxlabs.com/pricing' },
            { label: 'Interactive Demo', href: 'https://www.novyxlabs.com/demo' },
          ],
        },
        {
          title: 'Community',
          items: [
            { label: 'Discord', href: 'https://discord.gg/PCxZ3tMj' },
            { label: 'X / Twitter', href: 'https://x.com/NovyxLabs' },
            { label: 'GitHub', href: 'https://github.com/novyxlabs' },
          ],
        },
      ],
      copyright: `© ${new Date().getFullYear()} Novyx Labs. All rights reserved.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['bash', 'json', 'python', 'typescript'],
    },
    tableOfContents: {
      minHeadingLevel: 2,
      maxHeadingLevel: 4,
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
