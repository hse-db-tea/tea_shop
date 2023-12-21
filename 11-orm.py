import sqlalchemy
import sqlalchemy.orm

login = 'postgres'
password = 'unbelievablePassword'
engine = sqlalchemy.create_engine(f'postgresql://{login}:{password}@localhost/postgres')

with engine.connect() as connection:
    connection.execute(sqlalchemy.text('set search_path = project'))
    
base = sqlalchemy.orm.declarative_base()

class Product(base):
    __tablename__  = 'product'
    __table_args__ = {'schema': 'project'}
    product_id     = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True)
    valid_from     = sqlalchemy.Column(sqlalchemy.DateTime, primary_key=True)
    valid_to       = sqlalchemy.Column(sqlalchemy.DateTime)
    name           = sqlalchemy.Column(sqlalchemy.String)
    contents       = sqlalchemy.Column(sqlalchemy.String)
    price          = sqlalchemy.Column(sqlalchemy.Integer)

shop = sqlalchemy.orm.sessionmaker(bind=engine)
session = shop()

insert_product = Product(
    product_id=8, 
    valid_from='2023-02-01', 
    valid_to='2023-07-30', 
    name='Ясность Утра 2', 
    contents='Насладитесь чаем \"Ясность Утра 2\" — зеленый чай с акцентами жасмина и персика, наполняющий моментами спокойствия под утренним солнцем.',
    price=9000
)
session.add(insert_product)
session.commit()

delete_product = session.query(Product).filter_by(product_id=8).first()
session.delete(delete_product)
session.commit()

update_product = session.query(Product).filter_by(product_id=7).first()
update_product.valid_to = '2023-12-31'
update_product.price = '666'
session.commit()

for product in session.query(Product):
    print('name: ',       product.name)
    print('price: ',      product.price)
    print('valid_from: ', product.valid_from)
    print('valid_to: ',   product.valid_to)
    print('-' * 32)
