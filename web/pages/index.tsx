import type { NextPage } from 'next'
import styles from '../styles/Home.module.css'
import dynamic from 'next/dynamic'

const Home: NextPage = () => {

  const MapWithNoSSR = dynamic(() => import("../components/map"), {
    ssr: false
  });


  return (
    <div className={styles.container}>
      <MapWithNoSSR></MapWithNoSSR>
    </div >
  )
}

export default Home;