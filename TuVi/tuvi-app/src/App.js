import React, { useState } from 'react';
import styled from 'styled-components';
import { OpenAI, OpenAIError } from 'openai'; // Import OpenAI from openai package

// Styled components
const PageWrapper = styled.div`
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: url('https://img.freepik.com/free-photo/photo-wall-texture-pattern_58702-14880.jpg?t=st=1720554047~exp=1720557647~hmac=01deefafc6e7a8a0b06800ac4abd955a7ce75046ca97391b71f92214721770ef&w=826') no-repeat center center fixed;
  background-size: cover;
`;

const Container = styled.div`
  max-width: 600px;
  width: 100%;
  margin: 20px;
  padding: 20px;
  border-radius: 10px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
`;

const Input = styled.input`
  padding: 10px;
  margin: 10px 0;
  border: 1px solid #ccc;
  border-radius: 5px;
  background-color: #f9f9f9;
`;

const Select = styled.select`
  padding: 10px;
  margin: 10px 0;
  border: 1px solid #ccc;
  border-radius: 5px;
  background-color: #f9f9f9;
`;

const Button = styled.button`
  padding: 15px;
  margin: 20px 0;
  background-color: gray;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;

  &:hover {
    background-color: black;
  }
`;

const Loading = styled.p`
  text-align: center;
`;

const Error = styled.p`
  color: red;
  text-align: center;
`;

const Horoscope = styled.div`
  margin-top: 20px;
  padding: 20px;
  border-radius: 5px;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
`;

const HoroscopeTitle = styled.h2`
  text-align: center;
  color: #333;
`;

function HoroscopeForm() {
  const [formData, setFormData] = useState({
    name: '',
    birthDate: '',
    birthTime: '',
    gender: 'Nam',
    viewYear: 2024,
    lunarMonth: 6,
  });

  const [horoscope, setHoroscope] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setHoroscope('');

    const inputText = `Name: ${formData.name},
                      Birth Date: ${formData.birthDate},
                      Birth Time: ${formData.birthTime},
                      Gender: ${formData.gender},
                      View Year: ${formData.viewYear},
                      Lunar Month: ${formData.lunarMonth}`;

    try {
      console.log(process.env.REACT_APP_OPENAI_API_KEY);


      // const openai = new OpenAI({
      //   apiKey: process.env.REACT_APP_OPENAI_API_KEY,
      // });
      let openai = null;
      try {
        openai = new OpenAI({
          apiKey: process.env.REACT_APP_OPENAI_API_KEY,
          organization: "org-VJwySHuvg27VOVvdjsnxyaYS",
          project: "proj_zFXKYn6unl0ulqAOff0gmm7Q",
          dangerouslyAllowBrowser: true,// Replace with your project ID
        });
      }
      catch (error) {
        if (error instanceof OpenAIError) {
          console.error('OpenAI Error:', error.message);
        } else {
          console.error('Unexpected Error:', error);
        }
      }
      console.log(openai);
      let response = null;
      try {
        // const response = await openai.completions.create({
        //   model: "gpt-3.5-turbo",
        //   prompt: "Your prompt here",
        //   max_tokens: 256,
        // });
        response = await openai.chat.completions.create({
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: inputText }],
        });
        console.log(response);
        // Process response
      } catch (error) {
        console.log(error);
        if (error.response && error.response.status === 402) {

          setError('You exceeded your current quota. Please upgrade your plan.');
        } else {
          setError('Error processing request.');
        }
      }


      // const response = await openai.completions.create({
      //   model: "gpt-3.5-turbo", // Adjust this to match your ChatGPT model
      //   prompt: inputText,
      //   max_tokens: 256,
      //   top_p: 1,
      //   frequency_penalty: 0,
      //   presence_penalty: 0,
      // });

      setHoroscope(response.data.choices[0].text); // Adjust based on API response structure
    } catch (error) {
      setError('Error generating response');
    } finally {
      setLoading(false);
    }
  };

  return (
    <PageWrapper>
      <Container>
        <Form onSubmit={handleSubmit}>
          <Input type="text" name="name" value={formData.name} onChange={handleChange} placeholder="Name" />
          <Input type="date" name="birthDate" value={formData.birthDate} onChange={handleChange} />
          <Input type="time" name="birthTime" value={formData.birthTime} onChange={handleChange} />
          <Select name="gender" value={formData.gender} onChange={handleChange}>
            <option value="Nam">Nam</option>
            <option value="Nữ">Nữ</option>
          </Select>
          <Input type="number" name="viewYear" value={formData.viewYear} onChange={handleChange} />
          <Input type="number" name="lunarMonth" value={formData.lunarMonth} onChange={handleChange} />
          <Button type="submit">Lập lá số</Button>
        </Form>

        {loading && <Loading>Loading...</Loading>}
        {error && <Error>{error}</Error>}
        {horoscope && (
          <Horoscope>
            <HoroscopeTitle>Your Horoscope</HoroscopeTitle>
            <p>{horoscope}</p>
          </Horoscope>
        )}
      </Container>
    </PageWrapper>
  );
}

export default HoroscopeForm;
