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
    title: 'Clean API',
    emoji: '\u2728',
    description: (
      <>
        Write less boilerplate. Get full IDE autocomplete from <code>ref.</code> — discover
        every provider, method, and command without memorizing names.
      </>
    ),
  },
  {
    title: 'Side Effects',
    emoji: '\u26A1',
    description: (
      <>
        Stop writing loading/error/success tracking for every API call.
        Add <code>@command</code> and get independent state management with concurrency control for free.
      </>
    ),
  },
  {
    title: 'Pagination',
    emoji: '\uD83D\uDCC4',
    description: (
      <>
        Build infinite scroll lists without managing page state, controllers, or loading indicators yourself.
        Just define your data source.
      </>
    ),
  },
  {
    title: 'Fast Generation',
    emoji: '\uD83D\uDE80',
    description: (
      <>
        Save a file, see generated code instantly. No more waiting seconds (or minutes)
        for code generation to finish.
      </>
    ),
  },
];

function Feature({title, emoji, description}: FeatureItem) {
  return (
    <div className={clsx('col col--3')}>
      <div className="text--center" style={{fontSize: '2.5rem', marginBottom: '0.8rem'}}>
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
