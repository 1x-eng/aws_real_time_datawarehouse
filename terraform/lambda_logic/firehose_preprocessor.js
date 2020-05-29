'use strict';
console.log('DW Firehose PreProcessor Lambda Loading...');

exports.handler = async (event, context) => {
    let success = 0;
    let failure = 0;
    const output = event.records.map((record) => {
        /* Data is base64 encoded, so decode here */
        // const recordData = Buffer.from(record.data, 'base64');
        try {
            /*
             * Note: Any custom pre-processing logic to be coded in here.
             */
            success++;
            return {
                recordId: record.recordId,
                result: 'Ok',
                data: record.data
            };
        } catch (err) {
            failure++;
            return {
                recordId: record.recordId,
                result: 'DeliveryFailed',
            };
        }
    });
    console.log(`Successful delivered records ${success}, Failed delivered records ${failure}.`);
    return { records: output };
};