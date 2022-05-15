import { MapContainer, Marker, Popup, TileLayer, Circle } from 'react-leaflet'
import L, { LatLngTuple } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { useState, useEffect } from 'react';
import React from 'react';

function getWindowDimensions() {
    const { innerWidth: width, innerHeight: height } = window;
    return {
        width,
        height
    };
}

export function useWindowDimensions() {
    const [windowDimensions, setWindowDimensions] = useState(getWindowDimensions());

    useEffect(() => {
        function handleResize() {
            setWindowDimensions(getWindowDimensions());
        }

        window.addEventListener('resize', handleResize);
        return () => window.removeEventListener('resize', handleResize);
    }, []);

    return windowDimensions;
}

interface CircleWithNumberProps {
    width: number;
    height: number;
    number: number;
    position: LatLngTuple;
}

const CircleWithNumber = (props: CircleWithNumberProps) => {
    const width = props.height / 10;
    const height = props.height / 10;
    const css = "background-color:#388e3c; color: white; border: 5px #1b5E20 solid; justify-content: center;align-items: center;border-radius: 100%;text-align: center;display: flex;"
    const html = `<div style="width: ${width}px; height: ${height}px; ${css}">${props.number}</div>`

    return <Marker position={props.position} icon={L.divIcon({
        html, iconSize: [width, height],
        className: undefined
    })}></Marker>
}

interface MapState {
    width: number;
    height: number;
}
class Map extends React.Component<{}, MapState> {

    state = { width: 0, height: 0 };

    constructor(props: {}) {
        super(props);
        this.updateWindowDimensions = this.updateWindowDimensions.bind(this);
    }

    componentDidMount() {
        this.updateWindowDimensions();
        window.addEventListener('resize', this.updateWindowDimensions);
    }

    componentWillUnmount() {
        window.removeEventListener('resize', this.updateWindowDimensions);
    }

    updateWindowDimensions() {
        this.setState({ width: window.innerWidth, height: window.innerHeight });
    }


    render() {
        const positions: LatLngTuple[] = [[50.5, 30.5], [40.5, 30.5], [50.5, 40.5], [8.5, 30.5], [10.5, 30.5]]
        const markers = positions.map((position) => <CircleWithNumber width={this.state.width} height={this.state.height} number={32} position={position}></CircleWithNumber>)
        return (
            <MapContainer center={[51.505, -0.09]} zoom={3} scrollWheelZoom={true} style={{ height: 800, width: "100%" }}>
                <TileLayer
                    attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                />

                {markers}

            </MapContainer>
        )
    }
}

export default Map