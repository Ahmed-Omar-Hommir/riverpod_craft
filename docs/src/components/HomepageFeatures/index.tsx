import type {ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type FeatureItem = {
  title: string;
  emoji: string;
  description: ReactNode;
};

const FeatureList: FeatureItem[] = [
  {
    title: 'Better Syntax',
    emoji: '\u2728',
    description: (
      <>
        Access providers via <code>ref.myProvider.watch()</code> instead of{' '}
        <code>ref.watch(myProvider)</code>. Call methods directly without{' '}
        <code>.notifier</code>. Your IDE autocompletes everything.
      </>
    ),
  },
  {
    title: 'Side Effect Solution',
    emoji: '\u26A1',
    description: (
      <>
        Handle async operations with <code>@command</code>. Each side effect
        gets its own loading/error/success state, independent from the data
        provider. Built-in concurrency control.
      </>
    ),
  },
  {
    title: 'Code Generation',
    emoji: '\uD83D\uDEE0\uFE0F',
    description: (
      <>
        Write simple annotated classes. The CLI generates all boilerplate:
        provider declarations, notifier classes, and typed accessor classes.
        Just run <code>riverpod_craft watch</code>.
      </>
    ),
  },
];

function Feature({title, emoji, description}: FeatureItem) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--center" style={{fontSize: '3rem', marginBottom: '1rem'}}>
        {emoji}
      </div>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{title}</Heading>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures(): ReactNode {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
