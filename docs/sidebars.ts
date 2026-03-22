import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'introduction',
    'getting-started',
    {
      type: 'category',
      label: 'Concepts',
      collapsed: false,
      items: [
        'concepts/better-syntax',
        'concepts/side-effects',
        'concepts/command',
        'concepts/settable-providers',
      ],
    },
    {
      type: 'category',
      label: 'Reference',
      collapsed: false,
      items: [
        'reference/annotations',
        'reference/state-types',
        'reference/cli',
      ],
    },
    'examples',
    'example-app',
  ],
};

export default sidebars;
