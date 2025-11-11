import { Test, TestingModule } from '@nestjs/testing';
import { VisitanteController } from './visitante.controller';
import { VisitanteService } from './visitante.service';
import { HttpException, HttpStatus } from '@nestjs/common';
import { UsersService } from '../../modules/users/users.service';
import { ApartamentoService } from '../../modules/apartamento/apartamento.service';



describe('VisitanteController', () => {
  let visitanteController: VisitanteController;
  let visitanteService: VisitanteService;
  let module: TestingModule;

  class VisitanteServiceMock {
    findVisitantesByApartamento = jest.fn();
  }

  beforeEach(async () => {
    module = await Test.createTestingModule({
      controllers: [VisitanteController],
      providers: [
      { provide: VisitanteService, useClass: VisitanteServiceMock },
      { provide: UsersService, useValue: { findOne: jest.fn() } },
      { provide: ApartamentoService, useValue: { findOne: jest.fn() } },
      ],
    }).compile();

    visitanteController = module.get<VisitanteController>(VisitanteController);
    visitanteService = module.get<VisitanteService>(VisitanteService);
  });


  //teste aceite
  it('deve retornar uma lista de visitantes quando o apartamentoId for válido', async () => {
    const id = '9';
    const result = [{ id: 1, name: 'Visitante Teste' }];

    const apartamentoService = module.get<ApartamentoService>(ApartamentoService);
    jest.spyOn(apartamentoService, 'findOne').mockResolvedValue({
          id: 332,
          name: '332',
          users: [],
          vaga: null,
          visitante: [],
          createdAt: new Date(),
          updatedAt: new Date(),
    });

    jest.spyOn(visitanteService, 'findVisitantesByApartamento').mockResolvedValue(result as any);

    expect(await visitanteController.findVisitantesByApartamento(id)).toEqual(result);
  });
  

  //teste de erro
  it('deve lançar erro 404 se não encontrar visitantes para o apartamentoId', async () => {
    const id = '999';
    jest.spyOn(visitanteService, 'findVisitantesByApartamento').mockRejectedValue(
      new HttpException('Apartamento not found', HttpStatus.NOT_FOUND),
    );

    try {
      await visitanteController.findVisitantesByApartamento(id);
    } catch (error) {
      expect(error.response.message).toBe('Apartamento not found');
      expect(error.status).toBe(404);
    }
  });

  // it('deve retornar uma lista de visitantes quando o apartamentoId for válido', async () => {
  //   const id = '9'; // ID do apartamento válido
  //   const result: Visitante[] = [
  //     {
  //       id: 1,
  //       name: 'Pedrao Carreteiro',
  //       document: '555555555555',
  //       phone: '3198546763',
  //       model: null,
  //       checkIn: null,
  //       checkOut: null,
  //       apartamentoId: 9,
  //       typeVisitant: TipoVisitante.PESSOAL,
  //       userId: 3,
  //       apartamento: {
  //         id: 332,
  //         name: '332',
  //         users: [],
  //         vaga: null,
  //         visitante: [],
  //         createdAt: new Date(),
  //         updatedAt: new Date(),
  //       },
  //       user: {
  //         id: 3,
  //         name: 'luiz',
  //         email: 'luiz@gmail.com',
  //         password: 'hashedpassword',
  //         apartamentoId: 332,
  //         createdAt: new Date(),
  //         updatedAt: new Date(),
  //         deletedAt: null,
  //         apartamento : {
  //           id: 332,
  //           name: '332',
  //           users: [],
  //           vaga: null,
  //           visitante: [],
  //           createdAt: new Date(),
  //           updatedAt: new Date(),
  //         },
  //         role: Role.RESIDENT, // or the appropriate role value
  //         vistante: [], // or appropriate mock visitante array
  //       },
  //       createdAt: new Date(),
  //       updatedAt: new Date(),
  //     },
  //     {
  //       id: 2,
  //       name: 'Thiago Andrade',
  //       document: '868688686',
  //       phone: '3123234234',
  //       model: null,
  //       checkIn: new Date('2025-05-25'),
  //       checkOut: new Date('2025-05-25'),
  //       apartamentoId: 9,
  //       typeVisitant: TipoVisitante.ENTREGADOR, // Replace with the correct value from TipoVisitante if needed
  //       userId: 3,
  //       apartamento: {
  //         id: 332,
  //         name: '332',
  //         users: [],
  //         vaga: null,
  //         visitante: [],
  //         createdAt: new Date(),
  //         updatedAt: new Date(),
  //       },
  //       user: {
  //         id: 3,
  //         name: 'thiago',
  //         email: 'thiago@gmail.com',
  //         password: 'hashedpassword',
  //         apartamentoId: 332,
  //         createdAt: new Date(),
  //         updatedAt: new Date(),
  //         deletedAt: null,
  //         apartamento: {
  //           id: 332,
  //           name: '332',
  //           users: [],
  //           vaga: null,
  //           visitante: [],
  //           createdAt: new Date(),
  //           updatedAt: new Date(),
  //         },
  //         role: Role.RESIDENT,
  //         vistante: [],
  //       },
  //       createdAt: new Date(),
  //       updatedAt: new Date(),
  //     },
  //   ];

  //   // Mock do método findVisitantesByApartamentoId
  //   jest.spyOn(visitanteService, 'findVisitantesByApartamento').mockResolvedValue(result);

  //   // Chama o método do controlador
  //   expect(await visitanteController.findVisitantesByApartamento(id)).toEqual(result);
  // });


});