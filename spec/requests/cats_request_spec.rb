require 'rails_helper'

RSpec.describe 'Cats', type: :request do

  cat_params = {
    cat: {
      name: 'Buster',
      age: 4,
      enjoys: 'Meow Mix, and plenty of sunshine.'
    }
  }

  it "gets a list of Cats" do
    # Create a new cat in the Test Database (this is not the same one as development)
    Cat.create(name: 'Felix', age: 2, enjoys: 'Walks in the park')

    # Make a request to the API
    get '/cats'

    # Convert the response into a Ruby Hash
    json = JSON.parse(response.body)

    # Assure that we got a successful response
    expect(response).to have_http_status(200)

    # Assure that we got one result back as expected
    expect(json.length).to eq 1
  end

  it "creates a cat" do
    # Send the request to the server
    post '/cats', params: cat_params

    # Assure that we get a success back
    expect(response).to have_http_status(200)

    # Look up the cat we expect to be created in the Database
    cat = Cat.first

    # Assure that the created cat has the correct attributes
    expect(cat.name).to eq 'Buster'
    expect(cat.age).to eq 4
    expect(cat.enjoys).to eq 'Meow Mix, and plenty of sunshine.'
  end

  it "edits a cat" do
    # Send the request to the server
    post '/cats', params: cat_params

    cat = Cat.first
    expect(cat.age).to eq 4

    new_cat_params = {
      cat: {
        name: 'Buster',
        age: 7,
        enjoys: 'Meow Mix, and plenty of sunshine.'
      }
    }

    patch "/cats/#{cat.id}", params: new_cat_params
    cat = Cat.find(cat.id)
    expect(response).to have_http_status(200)
    expect(cat.age).to eq 7
  end


  it "destroys a cat" do
    # Send the request to the server
    post '/cats', params: cat_params

    cat = Cat.first

    delete "/cats/#{cat.id}"

    expect(response).to have_http_status(200)
    cat = Cat.all
    expect(cat).to be_empty
end



  it "doesn't create a cat without a name" do
    cat_params = {
      cat: {
        age: 2,
        enjoys: 'Walks in the park'
      }
    }
    # Send the request to the  server
    post '/cats', params: cat_params
    # expect an error if the cat_params does not have a name
    expect(response.status).to eq 422
    # Convert the JSON response into a Ruby Hash
    json = JSON.parse(response.body)
    # Errors are returned as an array because there could be more than one, if there are more than one validation failures on an attribute.
    expect(json['name']).to include "can't be blank"
  end

  it "doesn't create a cat without an age" do
    cat_params = {
      cat: {
        name: 'Felix',
        enjoys: 'Walks in the park'
      }
    }
    post '/cats', params: cat_params
    expect(response.status).to eq 422
    json = JSON.parse(response.body)
    expect(json['age']).to include "can't be blank"
  end

  it "doesn't create a cat without enjoys" do
    cat_params = {
      cat: {
        name: 'Felix',
        age: 3
      }
    }
    post '/cats', params: cat_params
    expect(response.status).to eq 422
    json = JSON.parse(response.body)
    expect(json['enjoys']).to include "can't be blank"
  end

end
