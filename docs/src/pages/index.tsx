import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';
import CodeBlock from '@theme/CodeBlock';

import styles from './index.module.css';

const exampleCode = `@provider
class Notes extends _\$Notes {
  @override
  Future<List<Note>> create() => repo.getNotes();

  @override
  @command
  @droppable
  Future<Note> addNote({required String title}) async {
    final note = await repo.addNote(title: title);
    reload();
    return note;
  }
}`;

const usageCode = `// Watch the notes list
final state = ref.notesProvider.watch();

// Run a side effect
ref.notesProvider.addNoteCommand.run(title: 'Hello');

// Watch the side effect state (independent from notes list)
ref.notesProvider.addNoteCommand.watch().when(
  init: () => Text('Add'),
  loading: (_) => CircularProgressIndicator(),
);`;

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <Heading as="h1" className="hero__title">
          {siteConfig.title}
          <span className="badge--alpha">Alpha</span>
        </Heading>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/introduction">
            Get Started
          </Link>
          <Link
            className="button button--outline button--lg"
            style={{marginLeft: '1rem', color: 'white', borderColor: 'rgba(255,255,255,0.5)'}}
            href="https://github.com/Ahmed-Omar-Hommir/riverpod_craft">
            GitHub
          </Link>
        </div>
      </div>
    </header>
  );
}

function CodeShowcase(): ReactNode {
  return (
    <section style={{padding: '4rem 0', background: 'var(--ifm-background-surface-color)'}}>
      <div className="container">
        <div className="row">
          <div className="col col--6">
            <Heading as="h2">Define your provider</Heading>
            <p>Write annotated classes. The CLI generates everything else.</p>
            <CodeBlock language="dart">{exampleCode}</CodeBlock>
          </div>
          <div className="col col--6">
            <Heading as="h2">Use it in your widgets</Heading>
            <p>Clean, type-safe API with IDE autocomplete.</p>
            <CodeBlock language="dart">{usageCode}</CodeBlock>
          </div>
        </div>
      </div>
    </section>
  );
}

function InstallSection(): ReactNode {
  return (
    <section style={{padding: '3rem 0'}}>
      <div className="container text--center">
        <Heading as="h2">Install in seconds</Heading>
        <div style={{maxWidth: 500, margin: '1.5rem auto'}}>
          <CodeBlock language="bash">
            {'dart pub global activate riverpod_craft_cli\nriverpod_craft watch'}
          </CodeBlock>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  return (
    <Layout
      title="Home"
      description="A code generation toolkit for Riverpod state management in Flutter">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <CodeShowcase />
        <InstallSection />
      </main>
    </Layout>
  );
}
