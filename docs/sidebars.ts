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
        'concepts/state-provider',
        'concepts/fetch-data',
        'concepts/pagination',
        'concepts/side-effects',
        'concepts/command',
        'concepts/why-craft-runner',
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
    {
      type: 'category',
      label: 'Advanced',
      collapsed: false,
      items: [
        'advanced/reusable-component',
      ],
    },
    {
      type: 'category',
      label: 'Examples',
      collapsed: false,
      link: {type: 'doc', id: 'examples/index'},
      items: [
        'examples/counter',
        'examples/quote',
        'examples/notes',
        'examples/movies-app',
        'examples/command-strategies',
      ],
    },
  ],
};

export default sidebars;
