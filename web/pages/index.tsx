import type { NextPage } from 'next'
import styles from '../styles/Home.module.css'
import dynamic from 'next/dynamic'
import { Divider, Grid, Stack } from '@mui/material'

const HeaderComponent = () => {
  return (
    <>
      <Grid container spacing={2} style={{ backgroundColor: "green", color: "white", paddingLeft: "20px", paddingRight: "20px" }} alignItems="center">
        <Grid item xs={6}>
          <h1>Clean the Planet</h1>
        </Grid>
        <Grid item xs={6}>
          <Stack
            direction="row"
            justifyContent="center"
            spacing={2} divider={<Divider orientation="vertical" flexItem />}>
            <div>Statistiken</div>
            <div>Wie funktioniert's?</div>
            <div>Unsere Mission</div>
          </Stack>
        </Grid>
      </Grid>
    </>)
}

const Home: NextPage = () => {

  const MapWithNoSSR = dynamic(() => import("../components/map"), {
    ssr: false
  });


  return (
    <>
      <HeaderComponent></HeaderComponent>
      <MapWithNoSSR></MapWithNoSSR>
    </ >
  )
}

export default Home;