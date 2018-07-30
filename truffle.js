module.exports = {

networks: {
    ganache: {
        // gas: 4.5 * 1e6,
        gasPrice: 2e9,
        network_id: '*',
        host: '127.0.0.1',
        port: 7545
    },
    testrpc: {
        // gas: 4.5 * 1e6,
        gasPrice: 2e9,
        network_id: '*',
        host: '127.0.0.1',
        port: 9545
    }
},
solc: {
    optimizer: {
        enabled: true,
        runs: 200
    }
}

};
