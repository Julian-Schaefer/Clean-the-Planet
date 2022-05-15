import type { NextPage } from 'next'
import styles from '../styles/Home.module.css'
import dynamic from 'next/dynamic'
import { Layout, Button } from 'antd';

const { Header, Footer, Sider, Content } = Layout;

const HeaderComponent = () => {
  return (
    <>
      <Layout>
        <Content>
          <h1>Clean the Planet</h1>
        </Content>
        <Sider><Button>Sign In</Button></Sider>
      </Layout>
    </>)
}

const Home: NextPage = () => {

  const MapWithNoSSR = dynamic(() => import("../components/map"), {
    ssr: false
  });


  return (
    <>
      <Layout>
        <Header>
          <HeaderComponent></HeaderComponent>

        </Header>
        <Content>
          <MapWithNoSSR></MapWithNoSSR>
        </Content>
      </Layout>
    </ >
  )
}

export default Home;