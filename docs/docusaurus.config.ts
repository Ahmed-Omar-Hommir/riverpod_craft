import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Riverpod Craft',
  tagline: 'A code generation toolkit for Riverpod',
  favicon: 'img/favicon.ico',

  future: {
    v4: true,
  },

  url: 'https://ahmed-omar-hommir.github.io',
  baseUrl: '/riverpod_craft/',

  organizationName: 'Ahmed-Omar-Hommir',
  projectName: 'riverpod_craft',

  trailingSlash: false,
  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          editUrl:
            'https://github.com/Ahmed-Omar-Hommir/riverpod_craft/tree/master/docs/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      defaultMode: 'dark',
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'Riverpod Craft',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'docsSidebar',
          position: 'left',
          label: 'Docs',
        },
        {
          href: 'https://pub.dev/packages/riverpod_craft',
          label: 'pub.dev',
          position: 'right',
        },
        {
          href: 'https://github.com/Ahmed-Omar-Hommir/riverpod_craft',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Getting Started',
              to: '/docs/introduction',
            },
            {
              label: 'Better Syntax',
              to: '/docs/concepts/better-syntax',
            },
            {
              label: 'Side Effects',
              to: '/docs/concepts/side-effects',
            },
          ],
        },
        {
          title: 'Reference',
          items: [
            {
              label: 'Annotations',
              to: '/docs/reference/annotations',
            },
            {
              label: 'State Types',
              to: '/docs/reference/state-types',
            },
            {
              label: 'CLI',
              to: '/docs/reference/cli',
            },
          ],
        },
        {
          title: 'Links',
          items: [
            {
              label: 'GitHub',
              href: 'https://github.com/Ahmed-Omar-Hommir/riverpod_craft',
            },
            {
              label: 'pub.dev',
              href: 'https://pub.dev/packages/riverpod_craft',
            },
            {
              label: 'Riverpod',
              href: 'https://riverpod.dev',
            },
          ],
        },
      ],
      copyright: `Copyright ${new Date().getFullYear()} Ahmed Omar Hommir. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['dart', 'yaml', 'bash'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
