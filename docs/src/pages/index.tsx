import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';
import CodeBlock from '@theme/CodeBlock';

import styles from './index.module.css';

const providerCode = `@provider
Future<List<Note>> notes(Ref ref) async {
  final response = await http.get(
    Uri.parse('https://api.example.com/notes'),
  );
  return (jsonDecode(response.body) as List)
      .map(Note.fromJson)
      .toList();
}`;

const widgetCode = `final state = ref.notesProvider.watch();

state.when(
  loading: () => CircularProgressIndicator(),
  data: (notes) => ListView(...),
  error: (e) => Text('Error: \$e'),
);

ref.notesProvider.reload();
ref.notesProvider.invalidate();`;

const commandCode = `@command
@droppable
Future<void> saveNote(Ref ref, {
  required String title,
  required String body,
}) async {
  await http.post(
    Uri.parse('https://api.example.com/notes'),
    body: jsonEncode({'title': title, 'body': body}),
  );
}`;

const commandUsageCode = `// Run the command
ref.saveNoteCommand.run(title: 'Hello', body: '...');

// Watch its state (independent from data)
final state = ref.saveNoteCommand.watch();

state.when(
  init: () => Text('Save'),
  loading: (_) => CircularProgressIndicator(),
  data: (_, __) => Text('Saved!'),
  error: (_, e) => Text('Failed: \$e'),
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
        <div className="text--center" style={{marginBottom: '2rem'}}>
          <Heading as="h2">Write less, do more</Heading>
          <p style={{fontSize: '1.1rem', color: 'var(--ifm-color-emphasis-700)'}}>
            Annotate your functions and classes — the generated code gives you a clean, type-safe API.
          </p>
        </div>
        <div className="row" style={{marginBottom: '3rem'}}>
          <div className="col col--6">
            <Heading as="h3">Define a provider</Heading>
            <CodeBlock language="dart">{providerCode}</CodeBlock>
          </div>
          <div className="col col--6">
            <Heading as="h3">Use in widgets</Heading>
            <CodeBlock language="dart">{widgetCode}</CodeBlock>
          </div>
        </div>
        <div className="row">
          <div className="col col--6">
            <Heading as="h3">Define a command</Heading>
            <CodeBlock language="dart">{commandCode}</CodeBlock>
          </div>
          <div className="col col--6">
            <Heading as="h3">Handle side effects</Heading>
            <CodeBlock language="dart">{commandUsageCode}</CodeBlock>
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
        <Heading as="h2">Get started in seconds</Heading>
        <div style={{maxWidth: 500, margin: '1.5rem auto'}}>
          <CodeBlock language="yaml" title="pubspec.yaml">
            {'dependencies:\n  riverpod_craft: ^0.1.0\n\ndev_dependencies:\n  craft_runner: ^0.1.0'}
          </CodeBlock>
          <CodeBlock language="bash">
            {'dart run craft_runner watch'}
          </CodeBlock>
        </div>
        <div style={{marginTop: '2rem'}}>
          <Link
            className="button button--primary button--lg"
            to="/docs/getting-started">
            Read the docs
          </Link>
        </div>
      </div>
    </section>
  );
}

export default function Home(): ReactNode {
  return (
    <Layout
      title="Home"
      description="Solutions and enhancements for Riverpod state management in Flutter">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
        <CodeShowcase />
      </main>
    </Layout>
  );
}
