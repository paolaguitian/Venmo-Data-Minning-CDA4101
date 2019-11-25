import response from './venmoResponse';

function getDataToArray(data = []) {
  return data.reduce((acc, payment) => {
    const item = [payment.username, payment.message];
    acc.push(item);

    return acc;
  },[])
}

console.log(getDataToArray(response.data));