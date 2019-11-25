import response from './venmoResponse';

function getDataToArray(data = []) {
  return data.reduce((acc, payment) => {
    acc.push(payment.username, payment.message);
    return acc;
  },[])
}
const finalForm = getDataToArray(response.data);
console.log(finalForm);
console.log(finalForm.length)

