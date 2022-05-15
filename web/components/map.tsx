import { MapContainer, Marker, TileLayer, useMapEvents } from 'react-leaflet'
import L, { LatLng, LatLngBounds, LatLngTuple } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import React, { useEffect, useState } from 'react';

interface CircleWithNumberProps {
    size: number;
    number: number;
    position: LatLngTuple;
}

const CircleWithNumber = (props: CircleWithNumberProps) => {
    const css = "background-color:#388e3c; color: white; border: 5px #1b5E20 solid; justify-content: center;align-items: center;border-radius: 100%;text-align: center;display: flex;"
    const html = `<div style="width: ${props.size}px; height: ${props.size}px; ${css}">${props.number}</div>`

    return <Marker position={props.position} icon={L.divIcon({
        html, iconSize: [props.size, props.size],
        className: undefined
    })}></Marker>
}

function getLineString(bounds: LatLngBounds) {
    let polylineString = "LINESTRING(";
    for (var coord of [bounds.getNorthWest(), bounds.getSouthEast()]) {
        polylineString +=
            coord.lat.toString() + " " + coord.lng.toString() + ",";
    }

    polylineString = polylineString.substring(0, polylineString.length - 1);

    return polylineString + ")";
}

function fromPointString(pointString: string): LatLng {
    pointString = pointString.substring("POINT(".length);
    pointString = pointString.substring(0, pointString.length - 1);

    const coords = pointString.split(" ");
    const latitude = Number(coords[0]);
    const longitude = Number(coords[1]);
    return new LatLng(latitude, longitude);
}

interface Statistic {
    id: string;
    address: string;
    centerPoint: LatLng;
    count: number;
}


function getWindowDimensions() {
    const { innerWidth: width, innerHeight: height } = window;
    return {
        width,
        height
    };
}

function useWindowDimensions() {
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

function StatisticMarkers() {
    const [error, setError] = useState(null);
    const [isLoaded, setIsLoaded] = useState(false);
    const [statistics, setStatistics] = useState<Statistic[]>();
    const [bounds, setBounds] = useState<LatLngBounds>();
    const [zoom, setZoom] = useState(0);
    const { height, width } = useWindowDimensions();

    const map = useMapEvents({
        moveend() {
            setBounds(map.getBounds());
            setZoom(map.getZoom())
            console.log(map.getBounds());
            getStatistics();
        },
        zoomend() {
            setBounds(map.getBounds());
            setZoom(map.getZoom())
            console.log(map.getBounds);
            getStatistics();
        },
        resize() {
            setBounds(map.getBounds());
            setZoom(map.getZoom())
            console.log(map.getBounds);
            getStatistics();
        }
    })

    const getStatistics = () => {
        if (!bounds || !zoom) return;

        const url = "http://localhost:5000/statistics?bounds=" +
            getLineString(bounds) +
            "&zoom=" +
            zoom.toString();

        fetch(url)
            .then(res => res.json())
            .then(
                (statistics: any[]) => {
                    statistics.map((statistic) => {
                        statistic.centerPoint = fromPointString(statistic.centerPoint);
                    });

                    statistics = statistics as Statistic[];

                    setStatistics(statistics);
                    setIsLoaded(true);
                },
                // Note: it's important to handle errors here
                // instead of a catch() block so that we don't swallow
                // exceptions from actual bugs in components.
                (error) => {
                    setIsLoaded(true);
                    setError(error);
                }
            )
    };

    if (!statistics) return null;

    const markers = statistics.map((statistic) => {
        const size = height / statistics.length * statistic.count;
        return <CircleWithNumber size={size} number={statistic.count} position={[statistic.centerPoint.lat, statistic.centerPoint.lng]}></CircleWithNumber>
    })
    return <div>{markers}</div>;
}

interface MapState {
    width: number;
    height: number;
}

const Map = () => {
    return (
        <MapContainer center={[51.505, -0.09]} zoom={3} scrollWheelZoom={true} style={{ height: 800, width: "100%" }}>
            <TileLayer
                attribution='&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
            />

            <StatisticMarkers />

        </MapContainer>
    )
}

export default Map